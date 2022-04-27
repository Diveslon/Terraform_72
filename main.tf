provider "aws" {
  region     = "us-east-1"
}

data "aws_ami" "mytest" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "192.168.100.0/24"
  availability_zone = "us-east-1"
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["192.168.100.201"]
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.mytest.id
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "HelloUbuntu"
  }
}
