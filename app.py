from flask import Flask, render_template, request, redirect, url_for, session
import boto3
import io
from PIL import Image

app = Flask(__name__)

# Set a simple secret key for session handling (testing purposes)
app.secret_key = 'my_test_secret_key_12345'  

rekognition = boto3.client('rekognition', region_name='us-east-1')
dynamodb = boto3.client('dynamodb', region_name='us-east-1')

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        try:
            image_file = request.files.get('image_path')
            if not image_file or not image_file.filename.lower().endswith(('jpg', 'jpeg', 'png')):
                session['error'] = "Invalid file type. Please upload a JPG or PNG image."
                return redirect(url_for('result'))

            image = Image.open(image_file)
            stream = io.BytesIO()
            image.save(stream, format="JPEG")
            image_binary = stream.getvalue()

            # Detect faces before searching
            detect_response = rekognition.detect_faces(
                Image={'Bytes': image_binary},
                Attributes=['DEFAULT']
            )
            if not detect_response['FaceDetails']:
                session['error'] = "No face detected in the image. Please upload a clear front-facing photo."
                return redirect(url_for('result'))

            response = rekognition.search_faces_by_image(
                CollectionId='face-rekognition-collection',
                Image={'Bytes': image_binary}
            )

            if 'FaceMatches' not in response or not response['FaceMatches']:
                session['error'] = "Face detected but no matching faces found in collection."
                return redirect(url_for('result'))

            recognized_faces = []
            for match in response['FaceMatches']:
                face_id = match['Face']['FaceId']
                face = dynamodb.get_item(
                    TableName='faceprints-table',
                    Key={'"Rekognitionid"': {'S': face_id}}
                )

                if 'Item' in face:
                    full_name = face['Item'].get('FullName', {}).get('S', 'Unknown')
                    similarity = round(match['Similarity'], 2)
                    recognized_faces.append(f"{full_name} (Match: {similarity}%)")

            if recognized_faces:
                session['recognized_faces'] = recognized_faces
            else:
                session['error'] = "Match found, but no metadata found in DynamoDB."

            return redirect(url_for('result'))

        except Exception as e:
            session['error'] = f"An error occurred: {e}"
            return redirect(url_for('result'))

    return render_template('index.html')

@app.route('/result')
def result():
    error = session.pop('error', None)
    recognized_faces = session.pop('recognized_faces', None)
    return render_template('result.html', error=error, recognized_faces=recognized_faces)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=81, debug=True)
