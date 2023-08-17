variable "region" {
  type    = string
  default = "us-east-1"
}

variable "key" {
  type    = string
  default = "mykey"
}

variable "type" {
  type    = string
  default = "t2.micro"
}

variable "vpc" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instances" {
  type    = list(string)
  default = ["prometheus"]
}

variable "subnets" {
  type    = list(string)
  default = ["10.0.0.0/24"]
}

