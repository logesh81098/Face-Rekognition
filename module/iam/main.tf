#################################################################################################################################################
#                                                       IAM Role
#################################################################################################################################################
#IAM Role for Lambda function to Create, List and Delete collection ID in AWS Rekogntion Service

resource "aws_iam_role" "rekognition-collection-id-role" {
  name = "Rekognition-Collection-ID"
  description = "IAM Role for Lambda function to Create, List and Delete collection ID in AWS Rekogntion Service"
  tags = {
    Name = "rekognition-collection-id-role"
    Project = "Face Rekognition"
  }
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        }
    }
    ]
}
EOF
}

#################################################################################################################################################
#                                                       IAM Policy
#################################################################################################################################################
#IAM policy for Lambda function to Create, List and Delete collection ID in AWS Rekogntion Service

resource "aws_iam_policy" "rekognition-collection-id-policy" {
  name = "Rekognition-Collection-ID-policy"
  description = "IAM policy for Lambda function to Create, List and Delete collection ID in AWS Rekogntion Service"
  tags = {
    Name = "Rekognition-Collection-ID-policy"
    Project = "Face Rekognition"
  }
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudWatchLogGroup",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "CreateRekognitionCollectionID",
            "Effect": "Allow",
            "Action": [
                "rekognition:CreateCollection",
                "rekognition:DeleteCollection",
                "rekognition:ListCollections"
            ],
            "Resource": "*"
        }
    ]
}  
EOF
}


#################################################################################################################################################
#                                                IAM Role and Policy attachement
#################################################################################################################################################
resource "aws_iam_role_policy_attachment" "rekognition-collection-id" {
  role = aws_iam_role.rekognition-collection-id-role.id
  policy_arn = aws_iam_policy.rekognition-collection-id-policy.arn
}



#################################################################################################################################################
#                                                       IAM Role
#################################################################################################################################################
#IAM Role for Lambda function to process (Index face) the image from the S3 bucket

resource "aws_iam_role" "faceprints-role" {
  name = "Rekognition-Faceprints"
  description = "IAM Role for Lambda function to process (Index face) the image from the S3 bucket"
  tags = {
    Name = "Rekognition-Faceprints"
    Project = "Face Rekognition"
  }
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }
    ]
}   
EOF
}

#################################################################################################################################################
#                                                       IAM Policy
#################################################################################################################################################
#IAM policy for Lambda function to create face prints from source s3 bucket

resource "aws_iam_policy" "face-prints-policy" {
  name = "Rekognition-Faceprints-policy"
  description = "IAM policy for Lambda function to create face prints from source s3 bucket"
  tags = {
    Name = "Rekognition-Faceprints-Poilcy"
    Project = "Face Rekognition"
  }
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateCloudWatchLogGroup",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "RecogniseFacePrints",
            "Effect": "Allow",
            "Action": [
                "rekognition:IndexFaces"
            ],
            "Resource": "arn:aws:rekognition:*:*:collection/*"
        },
        {
            "Sid": "CollectImagesFromS3",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:HeadObject"
            ],
            "Resource": "arn:aws:s3:::face-rekognition-source-bucket/*"
        },
        {
            "Sid": "IndexFacePrintsDynamoDB",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/faceprints-table"
        }
        
    ]
}  
EOF
}


#################################################################################################################################################
#                                                IAM Role and Policy attachement
#################################################################################################################################################
resource "aws_iam_role_policy_attachment" "face-prints-attachement" {
  role = aws_iam_role.faceprints-role.id
  policy_arn = aws_iam_policy.face-prints-policy.arn
}

#################################################################################################################################################
#                                                       IAM Role
#################################################################################################################################################
#IAM Role for EC2 instances 

