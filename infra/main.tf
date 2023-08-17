resource "aws_vpc" "monitoring-vpc" {
  cidr_block = var.vpc
  tags       = { "Name" : "Monitoring-VPC" }
}


resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.monitoring-vpc.id
  tags = {
    "Name" = "Monitoring-IGW"
  }
}


resource "aws_subnet" "monitoring-subnet" {
  count                   = length(var.subnets)
  cidr_block              = var.subnets[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.monitoring-vpc.id
  tags                    = { "Name" : "Monitoring-subnet-${count.index}" }

}


resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.monitoring-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}


resource "aws_route_table_association" "Public-RT-Association" {
  count          = length(var.subnets)
  subnet_id      = aws_subnet.monitoring-subnet[count.index].id
  route_table_id = aws_route_table.Public-RT.id
}

resource "aws_security_group" "Monitoring-SG" {
  name        = "Monitoring-SG"
  description = "Allow SSH and HTTP inbound traffic for EC2 include Prometheus"
  vpc_id      = aws_vpc.monitoring-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Alert Manager"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "EC2-Ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}


resource "aws_instance" "EC2" {
  count                  = length(var.instances)
  ami                    = data.aws_ami.EC2-Ubuntu.id
  instance_type          = var.type
  subnet_id              = aws_subnet.monitoring-subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.Monitoring-SG.id]
  key_name               = var.key
  tags = {
    env = var.instances[count.index]
  }
}
