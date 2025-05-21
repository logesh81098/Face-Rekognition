import boto3
from decimal import Decimal
import json
import urllib.parse
import os

print('Loading function')

dynamodb = boto3.client('dynamodb')
s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')

# Environment variables for table and collection
DYNAMODB_TABLE = os.getenv('DYNAMODB_TABLE', 'Faceprints-Table')
REKOGNITION_COLLECTION = os.getenv('REKOGNITION_COLLECTION', 'face-rekognition-collection')

def index_faces(bucket, key):
    try:
        response = rekognition.index_faces(
            Image={"S3Object": {"Bucket": bucket, "Name": key}},
            CollectionId=REKOGNITION_COLLECTION
        )
        return response
    except Exception as e:
        print(f"Error in index_faces: {e}")
        raise

def update_index(table_name, face_id, full_name):
    try:
        response = dynamodb.put_item(
            TableName=table_name,
            Item={
                'Rekognitionid': {'S': face_id},  # Fixed key name
                'FullName': {'S': full_name}
            }
        )
        return response
    except Exception as e:
        print(f"Error in update_index: {e}")
        raise

def lambda_handler(event, context):
    try:
        records = event.get('Records', [])
        if not records:
            print("No records found in the event.")
            return {'statusCode': 400, 'body': 'No records found in the event.'}

        for record in records:
            bucket = record['s3']['bucket']['name']
            key = urllib.parse.unquote_plus(record['s3']['object']['key'])
            print(f"Processing object: s3://{bucket}/{key}")

            response = index_faces(bucket, key)
            
            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                face_records = response.get('FaceRecords', [])
                if not face_records:
                    print("No faces detected in the image.")
                    continue

                for face_record in face_records:
                    face_id = face_record['Face']['FaceId']
                    object_metadata = s3.head_object(Bucket=bucket, Key=key)
                    person_full_name = object_metadata['Metadata'].get('fullname', 'Unknown')

                    update_index(DYNAMODB_TABLE, face_id, person_full_name)
                    print(f"Face indexed successfully. FaceId: {face_id}, Full Name: {person_full_name}")
            else:
                print(f"Error indexing faces. Response: {response}")
                return {'statusCode': 500, 'body': 'Error indexing faces.'}
                
        return {'statusCode': 200, 'body': 'Processing completed.'}
    except Exception as e:
        print(f"Error processing event: {e}")
        return {'statusCode': 500, 'body': f"Error processing event: {e}"}