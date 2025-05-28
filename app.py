from flask import Flask, render_template, request
import boto3
import uuid
import os

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

AWS_REGION = 'us-east-1'
REKOGNITION_COLLECTION = 'face-rekognition-collection'
DYNAMODB_TABLE_NAME = 'Faceprints-Table'

# Initialize boto3 clients and resources
rekognition = boto3.client('rekognition', region_name=AWS_REGION)
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

def save_to_dynamo(face_id, filename):
    """
    Save Rekognition FaceId and filename to DynamoDB.
    """
    table.put_item(
        Item={
            'Rekognitionid': face_id,    # Primary key, case sensitive
            'ImageFilename': filename
        }
    )

def get_all_faces():
    """
    Scan DynamoDB table and return list of Rekognition FaceIds.
    """
    response = table.scan()
    return [item['Rekognitionid'] for item in response.get('Items', [])]

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    if 'image' not in request.files:
        return 'No file part in the request', 400
    
    file = request.files['image']
    if file.filename == '':
        return 'No selected file', 400
    
    if file:
        # Save file locally
        filename = str(uuid.uuid4()) + "_" + file.filename
        os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # Read image bytes for Rekognition
        with open(filepath, 'rb') as image_file:
            image_bytes = image_file.read()

        # Index face into Rekognition collection
        response = rekognition.index_faces(
            CollectionId=REKOGNITION_COLLECTION,
            Image={'Bytes': image_bytes},
            ExternalImageId=filename,
            DetectionAttributes=['DEFAULT']
        )

        if not response['FaceRecords']:
            return 'No face detected in the image.', 400

        face_id = response['FaceRecords'][0]['Face']['FaceId']

        # Save to DynamoDB
        save_to_dynamo(face_id, filename)

        # Search for face matches excluding the face just indexed
        matches = []
        all_face_ids = get_all_faces()
        for other_face_id in all_face_ids:
            if other_face_id == face_id:
                continue  # skip comparing to itself
            
            search_response = rekognition.search_faces(
                CollectionId=REKOGNITION_COLLECTION,
                FaceId=face_id,
                FaceMatchThreshold=90,
                MaxFaces=1
            )
            if search_response['FaceMatches']:
                matched_face_id = search_response['FaceMatches'][0]['Face']['FaceId']
                matches.append(matched_face_id)

        return render_template('result.html', face_id=face_id, matches=matches)

if __name__ == '__main__':
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    app.run(host='0.0.0.0', port=81, debug=True)
