module "s3" {
  source = "./module/s3"
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