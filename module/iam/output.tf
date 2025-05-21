output "rekognition-collection-id-arn" {
  value = aws_iam_role.rekognition-collection-id-role.arn
}

output "rekognition-faceprints-role-arn" {
  value = aws_iam_role.faceprints-role.arn
}