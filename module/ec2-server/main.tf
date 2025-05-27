################################################################################################################################################
#                                                          Key Pair
################################################################################################################################################

resource "tls_private_key" "face-rekognition" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "face-rekognition-key" {
  key_name = "face-rekognition-key"
  public_key = tls_private_key.face-rekognition.public_key_openssh
}

resource "local_file" "face-rekognition-key-private-key" {
  filename = "face-rekognition-key-private-key"
  content = tls_private_key.face-rekognition.private_key_openssh
}
#################################################################################################################################################
#                                                         EC2 Server
################################################################################################################################################
#EC2 server to launch application

resource "aws_instance" "face-rekognition-server" {
  ami = var.ami-id
  instance_type = var.instance-type
  subnet_id = var.subnet-id
  security_groups = [var.Face-Rekognition-SG]
  key_name = aws_key_pair.face-rekognition-key.key_name
  iam_instance_profile = var.rekognition-instance-profile
  tags = {
    Name = "Face-Rekognition-Server"
    Project = "Face-Rekognition"
  }
  user_data = <<-EOF
  #!/bin/bash
  sudo su
  set -eux
  dnf update -y
  dnf upgrade -y
  dnf install -y git 
  git --version
  dnf install -y docker
  sudo systemctl enable docker
  sudo systemctl start docker
  sleep 10
  sudo systemctl status docker
  usermod -aG docker ec2-user
  dnf install -y python3 python3-pip 
  pip install boto3
  cd /
  git clone https://github.com/logesh81098/Face-Rekognition.git
  cd Face-Rekognition/
  sudo python3 upload-images-to-s3.py
  sudo docker build -t face-rekognition-app .
  sudo docker run -d -p 81:81 face-rekognition-app
  sudo docker ps -a 
EOF
}