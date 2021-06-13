provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "example" {
  ami               = "ami-086850e3dda52e84a"
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"
  security_groups   = ["${aws_security_group.allow_rdp1.name}"]
  key_name = "keyec2"
}
resource "aws_security_group" "allow_rdp1" {
  name        = "allow_rdp1"
  description = "allow ssh traffic"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
