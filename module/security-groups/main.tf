#################################################################################################################################################
#                                                         Security Group
################################################################################################################################################
#Security to allow only necessary ports and IP to server

resource "aws_security_group" "face-rekognition-sg" {
  name = "Face-Rekognition-SG"
  description = "Allow only SSH port and docker port"
  vpc_id = var.vpc-id
  ingress {
    from_port = 22
    to_port = 22
    cidr_blocks = []
    protocol = "tcp"
  }
  ingress {
    from_port = 81
    to_port = 81
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }
  tags = {
    Name = "Face-Rekognition-Security Group"
    Project = "Face-Rekognition"
  }

}