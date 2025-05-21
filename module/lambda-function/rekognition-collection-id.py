import boto3
import json

def lambda_handler(event, context):
    # Initialize Rekognition client
    rekognition_client = boto3.client('rekognition')
    
    # Collection ID passed via event or hardcoded
    collection_id = event.get('collection_id', 'face-rekognition-collection')
    
    try:
        # Create a Rekognition collection
        response = rekognition_client.create_collection(CollectionId=collection_id)
        
        # Extracting information from the response
        status_code = response['StatusCode']
        collection_arn = response['CollectionArn']
        
        # Log success response
        print(f"Collection {collection_id} created successfully.")
        print("Response:", json.dumps(response, indent=4))
        
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": f"Collection {collection_id} created successfully.",
                "collection_id": collection_id,
                "collection_arn": collection_arn,
                "status_code": status_code
            })
        }
    except rekognition_client.exceptions.ResourceAlreadyExistsException:
        print(f"Collection {collection_id} already exists.")
        return {
            "statusCode": 400,
            "body": json.dumps({
                "message": f"Collection {collection_id} already exists.",
                "collection_id": collection_id
            })
        }
    except Exception as e:
        print(f"Error creating collection: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": f"Error creating collection: {str(e)}"
            })
        }