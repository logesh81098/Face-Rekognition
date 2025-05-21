terraform {
  backend "s3" {
    bucket = "terraform-backend-files-logesh"
    key = "face-rekognition"
    region = "us-east-1"
  }
}