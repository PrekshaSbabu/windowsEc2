provider "aws" {
  region = "us-east-2"
}
resource "aws_security_group" "webservers-ssh-http" {
  name        = "webservers-ssh-http"
  description = "allow ssh and http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webservers" {
  ami               = "ami-077e31c4939f6a2f3"
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"
  security_groups   = ["${aws_security_group.webservers-ssh-http.name}"]
  key_name = "keyec2"
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo "<h1>Sample Webserver demo page</h>" >> /var/www/html/index.html
  EOF


  tags = {
        Name = "webserver"
  }

}
