variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your public ip in CIDR"
}
