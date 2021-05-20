provider "aws" {
  region = var.region
}

module "vpc_basic" {
  source        = "./vpc_basic"
  name          = "web"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/25"
}

resource "aws_instance" "web" {
  ami = var.ami[var.region]
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = module.vpc_basic.public_subnet_id
  associate_public_ip_address = true
  user_data = file("files/web_bootstrap.sh")
  vpc_security_group_ids = ["aws_security_group.web_host_sg.id"]
  count =2 
}

resource "aws_elb" "web" {
  name = "web-elb"
  subnets = [module.vpc_basic.public_subnet_id]
  security_groups = [aws.security_group.web_inbound_sg.id]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  instances = aws_instance.web[*].id
}

resource "aws_security_group" "web_inbound_sg" {
  
}