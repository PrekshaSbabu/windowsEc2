provider "aws" {
  region = "${var.aws_region}"
}
#vpc
resource "aws_vpc" "terra_vpc" {
  cidr_block          = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = { 
    Name = "Terraform_vpc"
  }
}
#internetgateways
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  tags = {
    Name = "main"
  }
}
#subnets
resource "aws_subnet" "public" {
  count                   = "${length(var.subnets_cidr)}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  cidr_block              = "${element(var.subnets_cidr,count.index)}"
  availability_zone       = "${element(var.azs,count.index)}"
  map_public_ip_on_launch = true
   tags = {
    Name = "Subnet.${count.index+1}"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_igw.id}"
  }
  tags = {
    Name = "PublicRouteTable"
  }
}
#route table association with public subnet
resource "aws_route_table_association" "a" {
  count = "${length(var.subnets_cidr)}"
  subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
resource "aws_security_group" "webservers" {
  name        = "allow_http"
  description = "allow http inbound traffic"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  ingress {
    description = "ssh from vpc"
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
  count             = "var.number_instances"
  ami               = "ami-077e31c4939f6a2f3"
  instance_type     = "t2.micro"
  #availability_zone = "us-east-2a"
  security_groups   = ["${aws_security_group.webservers.id}"]
  subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
  key_name = "keyec2"
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo " hey i am $(hostname -f)" > /var/www/html/index.html
                service httpd start
                chkconfig httpd on
                EOF


  tags = {
        Name = "Server.${count.index}"
  }

}
#loadbalancer 
resource "aws_elb" "terra_elb" {
  name               = "terra-elb"
  subnets = "${aws_subnet.public.*.id}"
  security_groups   = ["${aws_security_group.webservers.id}"]

   listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = "${aws_instance.webservers.*.id}"
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "terraform-elb"
  }
}

output "elb-dns-name" {
  value = "${aws_elb.terra-elb.dns_name}"
}

