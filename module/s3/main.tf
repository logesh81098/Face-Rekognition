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