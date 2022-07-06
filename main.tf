terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
  profile = "superhero"
}

resource "aws_vpc" "game-env" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "subnet-uno" {
  # creates a subnet
  cidr_block        = "${cidrsubnet(aws_vpc.game-env.cidr_block, 3, 1)}"
  vpc_id            = "${aws_vpc.game-env.id}"
  availability_zone = var.subnet_region
}

resource "aws_security_group" "ingress-all-singleip" {
  name   = "allow-ssh-sg"
  vpc_id = "${aws_vpc.game-env.id}"

  ingress {
    cidr_blocks = [
      var.allow_from_ip
    ]

    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-rdp" {
  name   = "allow-http-sg"
  vpc_id = "${aws_vpc.game-env.id}"

  ingress {
    cidr_blocks = [
      var.allow_from_ip
    ]

    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_eip" "ip-game-env" {
  instance = "${aws_spot_instance_request.game_vm.spot_instance_id}"
  vpc      = true
}

resource "aws_internet_gateway" "game-env-gw" {
  vpc_id = "${aws_vpc.game-env.id}"
}

resource "aws_route_table" "route-table-game-env" {
  vpc_id = "${aws_vpc.game-env.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.game-env-gw.id}"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-uno.id}"
  route_table_id = "${aws_route_table.route-table-game-env.id}"
}

resource "aws_key_pair" "spot_key" {
  key_name   = "spot_key"
  public_key = "${file("/home/vagrant/.ssh/id_rsa.pub")}"
}

resource "aws_volume_attachment" "game-vol" {
  device_name = "xvdf"
  volume_id = "vol-0f18c28e9a1f92837"
  instance_id = "${aws_spot_instance_request.game_vm.spot_instance_id}"
  stop_instance_before_detaching = true
  
}
resource "aws_spot_instance_request" "game_vm" {
  ami                    = "ami-0714e7069dcab7623"
  spot_price             = "0.816"
  instance_type          = "g4dn.xlarge"
  spot_type              = "one-time"
  block_duration_minutes = "0"
  wait_for_fulfillment   = "false"
  key_name               = "spot_key"

  security_groups = ["${aws_security_group.ingress-all-singleip.id}", "${aws_security_group.ingress-rdp.id}"]
  subnet_id = "${aws_subnet.subnet-uno.id}"

  tags = {
    Name = var.instance_name
  }
}
