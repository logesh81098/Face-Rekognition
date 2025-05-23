module "s3" {
  source = "./module/s3"
  rekognition-faceprints-arn = module.lambda-function.rekognition-faceprints-arn
}

module "iam" {
  source = "./module/iam"
}

module "lambda-function" {
  source = "./module/lambda-function"
  rekognition-collection-id-arn = module.iam.rekognition-collection-id-arn
  rekognition-faceprints-role-arn = module.iam.rekognition-faceprints-role-arn
  face-rekognition-source-bucket = module.s3.face-rekognition-source-bucket
}

module "dynamo-db" {
  source = "./module/Dynamo DB"
}

module "vpc" {
  source = "./module/vpc"
}

module "security-group" {
  source = "./module/security-groups"
  vpc-id = module.vpc.Face-Rekognition-VPC
}

module "ec2-server" {
  source = "./module/ec2-server"
  subnet-id = module.vpc.subnet-id
  Face-Rekognition-SG = module.security-group.security-group
  rekognition-instance-profile = module.iam.rekognition-instance-profile
}