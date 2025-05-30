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
            "Resource": "arn:aws:dynamodb:*:*:table/Faceprints-Table"
        }
        
    ]
}  
EOF
}


#################################################################################################################################################
#                                                IAM Role and Policy attachement
#################################################################################################################################################
resource "aws_iam_role_policy_attachment" "face-prints-attachment" {
  role = aws_iam_role.faceprints-role.id
  policy_arn = aws_iam_policy.face-prints-policy.arn
}

#################################################################################################################################################
#                                                       IAM Role
#################################################################################################################################################
#IAM Role for EC2 instances 

resource "aws_iam_role" "face-rekognition-ec2-role" {
  name = "Face-Rekognition-EC2-role"
  description = "EC2 Role for application to IndexFace and compare the existing faceprints"
  tags = {
    Name = "Face-Rekognition-EC2-role"
    Project = "Face-Rekognition"
  }
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }
    ]
}  
EOF
}

#################################################################################################################################################
#                                                       IAM Policy
#################################################################################################################################################
#IAM policy for EC2 Instance 

resource "aws_iam_policy" "face-rekogntion-ec2-policy" {
  name = "Face-Rekogntion-EC2-policy"
  description = "EC2 Policy for application to IndexFace and compare the existing faceprints"
  tags = {
    Name = "Face-Rekogntion-EC2-policy"
    Project = "Face-Rekogntion"
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
            "Sid": "DynamoDBGetItems",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:DescribeTable",
                "dynamodb:PutItem",
                "dynamodb:Scan"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/Faceprints-Table"
        },
        {
            "Sid": "RekognitionIndexFace",
            "Effect": "Allow",
            "Action": [
                "rekognition:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3PutSourceImage",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObject",
                "s3:HeadObject"
            ],
            "Resource": [
                "arn:aws:s3:::face-rekognition-source-bucket/*",
                "arn:aws:s3:::face-rekognition-source-bucket"
            ]
        }
    ]
}  
EOF
}


#################################################################################################################################################
#                                                IAM Role and Policy attachement
#################################################################################################################################################

resource "aws_iam_role_policy_attachment" "faceprints-ec2-role-policy-attachment" {
  role = aws_iam_role.face-rekognition-ec2-role.id
  policy_arn = aws_iam_policy.face-rekogntion-ec2-policy.arn
}

#################################################################################################################################################
#                                                   IAM Instance Profile
#################################################################################################################################################

resource "aws_iam_instance_profile" "face-prints-instance-profile" {
  role = aws_iam_role.face-rekognition-ec2-role.name
  name = "Face-Prints-Instance-Profile"
}