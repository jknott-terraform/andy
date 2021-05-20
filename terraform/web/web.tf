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
  ami                         = var.ami[var.region]
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = module.vpc_basic.public_subnet_id
  private_ip                  = var.instance_ips[count.index]
  associate_public_ip_address = true
  user_data                   = file("files/web_bootstrap.sh")
  vpc_security_group_ids      = ["aws_security_group.web_host_sg.id"]
  tags = {
    Name  = "web-${format("%03d", count.index)}"
    Owner = element(var.owner_tag, count.index)
  }
  count = length(var.instance_ips)
}

resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = [module.vpc_basic.public_subnet_id]
  security_groups = [aws.security_group.web_inbound_sg.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  instances = aws_instance.web[*].id
}

resource "aws_security_group" "web_inbound_sg" {
  name        = "web-inbound"
  description = "Allow HTTP from anywhere"
  vpc_id      = module.vpc_basic.vpc_id

  #plugin suggested list of objects so I'm trying that out
  ingress = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8
      to_port     = 0
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
  }]

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

resource "aws_security_group" "web_host_sg" {
  name        = "web_host"
  description = "Allow SSH & HTTP to web hosts"
  vpc_id      = module.vpc_basic.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_basic.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}