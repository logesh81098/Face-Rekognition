module "s3" {
  source = "./module/s3"
}

module "iam" {
  source = "./module/iam"
}

module "lambda-function" {
  source = "./module/lambda-function"
  rekognition-collection-id-arn = module.iam.rekognition-collection-id-arn
}

module "dynamo-db" {
  source = "./module/Dynamo DB"
}