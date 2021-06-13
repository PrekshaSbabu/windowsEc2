provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "example" {
  ami               = "ami-0fa60543f60171fe3"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  security_groups   = ["${aws_security_group.allow_rdp.name}"]
  key_name = "keyec2"
}
resource "aws_security_group" "allow_rdp" {
  name        = "allow_rdp"
  description = "allow ssh traffic"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
