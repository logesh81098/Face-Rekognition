#################################################################################################################################################
#                                                        Dynamo DB
#################################################################################################################################################
#Creating Dynamo DB to store the faceprints created by lambda function from the images of source bucket

resource "aws_dynamodb_table" "faceprints-table" {
  name = "Faceprints-Table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "Rekognitionid"
  attribute {
    type = "S"
    name = "Rekognitionid"
  }
  attribute {
    type = "S"
    name = "FullName"
  }
  global_secondary_index {
    name               = "FullName-index"
    hash_key           = "FullName"
    projection_type    = "ALL"  # You can change this depending on what attributes you need to project
    read_capacity      = 5
    write_capacity     = 5
  }
  tags = {
    Name = "Faceprints-Table"
    Project = "Face Rekognition"
  }
}