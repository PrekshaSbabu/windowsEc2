variable "aws_region" {
	default = "us-east-2"
}
variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr" {
	type = list
	default = ["10.20.1.0/24" , "10.20.2.0/24"]
}

variable "azs" {
	type = list
	default = ["us-east-1a" , "us-east-1b"]
}
variable "number_instance" {
  default = "2"
}
