from flask import Flask, render_template, request
import boto3
import uuid
import os

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Faceprints-Table')
collection_id = 'face-rekognition-collection'

def save_to_dynamo(face_id, image_name):
    table.put_item(
        Item={
            'FaceId': face_id,
            'ImageName': image_name
        }
    )

def get_all_faces():
    response = table.scan()
    return [item['FaceId'] for item in response.get('Items', [])]

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    if 'image' not in request.files:
        return 'No file part'
    
    file = request.files['image']
    if file.filename == '':
        return 'No selected file'
    
    if file:
        filename = str(uuid.uuid4()) + "_" + file.filename
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        with open(filepath, 'rb') as image:
            response = rekognition.index_faces(
                CollectionId=collection_id,
                Image={'Bytes': image.read()},
                ExternalImageId=filename,
                DetectionAttributes=['DEFAULT']
            )

        if not response['FaceRecords']:
            return 'No face detected.'

        face_id = response['FaceRecords'][0]['Face']['FaceId']
        save_to_dynamo(face_id, filename)

        matches = []
        for face in get_all_faces():
            if face == face_id:
                continue  # skip self match

            match_response = rekognition.search_faces(
                CollectionId=collection_id,
                FaceId=face_id,
                FaceMatchThreshold=90,
                MaxFaces=1
            )

            if match_response['FaceMatches']:
                matches.append(match_response['FaceMatches'][0]['Face']['FaceId'])

        return render_template('result.html', face_id=face_id, matches=matches)

if __name__ == '__main__':
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    app.run(debug=True)
