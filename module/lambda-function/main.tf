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