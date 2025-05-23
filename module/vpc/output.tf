output "Face-Rekognition-VPC" {
  value = aws_vpc.face-rekognition.id
}

output "subnet-id" {
  value = aws_subnet.public-subnet-1.id
}