from flask import Flask, render_template, request
import boto3
import uuid
import os

app = Flask(__name__)

# Constants
UPLOAD_FOLDER = 'uploads'
COLLECTION_ID = 'face-rekognition-collection'
DYNAMODB_TABLE_NAME = 'Faceprints-Table'
AWS_REGION = 'us-east-1'

# Configurations
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# AWS clients
rekognition = boto3.client('rekognition', region_name='us-east-1')
dynamodb = boto3.client('dynamodb', region_name='us-east-1')
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

# Save face info to DynamoDB
def save_to_dynamo(face_id, image_name):
    table.put_item(Item={'FaceId': face_id, 'ImageName': image_name})

# Get all stored face IDs from DynamoDB
def get_all_faces():
    response = table.scan()
    return [item['FaceId'] for item in response.get('Items', [])]

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    if 'image' not in request.files:
        return 'No file part', 400

    file = request.files['image']
    if file.filename == '':
        return 'No selected file', 400

    # Save file locally
    filename = str(uuid.uuid4()) + "_" + file.filename
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    # Index the face using Rekognition
    with open(filepath, 'rb') as image:
        response = rekognition.index_faces(
            CollectionId=COLLECTION_ID,
            Image={'Bytes': image.read()},
            ExternalImageId=filename,
            DetectionAttributes=['DEFAULT']
        )

    if not response['FaceRecords']:
        return 'No
