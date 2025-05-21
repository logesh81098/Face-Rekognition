#################################################################################################################################################
#                                                       Archive File
#################################################################################################################################################
#To create zip file formate of our rekognition-collection-id python code

data "archive_file" "collection-id" {
  type = "zip"
  source_dir = "module/lambda-function"
  output_path = "module/lambda-function/rekognition-collection-id.zip"
}

#################################################################################################################################################
#                                                     Lambda Function
#################################################################################################################################################
#Lambda Function to Create, List and Delete Rekognition Collection ID 

resource "aws_lambda_function" "rekognition-collection-id" {
  function_name = "Rekognition-Collection-ID"
  runtime = "python3.8"
  handler = "rekognition-collection-id.lambda_handler"
  role = var.rekognition-collection-id-arn
  filename = "module/lambda-function/rekognition-collection-id.zip"
  timeout = "20"
  tags = {
    Name = "Rekognition-Collection-ID"
    Project = "Face-Rekognition"
  }

}


#################################################################################################################################################
#                                                       Archive File
#################################################################################################################################################
#To create zip file formate of our face-print python code

data "archive_file" "faceprints" {
  type = "zip"
  source_dir = "module/lambda-function"
  output_path = "module/lambda-function/rekognition-faceprints.zip"
}

#################################################################################################################################################
#                                                       Lambda Function
#################################################################################################################################################
#Lambda Function to generate Face Index

resource "aws_lambda_function" "rekognition-faceprints" {
  function_name = "Rekognition-Faceprints"
  runtime = "python3.8"
  role = var.rekognition-faceprints-role-arn
  handler = "rekognition-faceprints.lambda_handler"
  filename = "module/lambda-function/rekognition-faceprints.zip"
  timeout = "20"
  tags = {
    Name =  "Rekognition-Faceprints"
    Project = "Face-Rekognition"
  }
}


#################################################################################################################################################
#                                                S3 to trigger Lambda Function
#################################################################################################################################################
#S3 bucket to trigger lambda function for each object upload


resource "aws_lambda_permission" "s3-to-invoke-lambda" {
    function_name = aws_lambda_function.rekognition-faceprints.function_name
    statement_id = "s3-to-trigger-lambda"
    principal = "s3.amazonaws.com"
    action = "lambda:InvokeFunction"
    source_arn = var.face-rekognition-source-bucket
}