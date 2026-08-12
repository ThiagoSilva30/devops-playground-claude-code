provider "aws" {
  region = var.region
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  tags = {
    Name = "devops-playground-app"
  }
}
