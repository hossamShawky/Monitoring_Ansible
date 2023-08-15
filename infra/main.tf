resource "aws_vpc" "monitoring-vpc" {
  cidr_block = var.vpc
}

resource "aws_subnet" "monitoring-subnet" {
  count                   = length(var.subnets)
  cidr_block              = var.subnets[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.monitoring-vpc.id
  tags                    = { "Name" : "Monitoring-subnet-var.[count.index]" }

}



