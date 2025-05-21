#################################################################################################################################################
#                                                        S3 Bucket
#################################################################################################################################################
#Creating S3 bucket to store source images 

resource "aws_s3_bucket" "source-bucket" {
  bucket = "face-rekognition-source-bucket"
  tags = {
    Name = "face-rekognition-source-bucket"
    Project = "Face Rekognition"
  }
}


#################################################################################################################################################
#                                                  S3 Bucket to trigger lambda
#################################################################################################################################################
#S3 to send notification for lambda function

resource "aws_s3_bucket_notification" "s3-trigger-lambda" {
  bucket = aws_s3_bucket.source-bucket.bucket
  lambda_function {
    lambda_function_arn = var.rekognition-faceprints-arn
    events = ["s3:ObjectCreated:*"]
  }
}