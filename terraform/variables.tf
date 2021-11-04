variable "profile" {
  type    = string
  default = "default"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "azone" {
  type    = string
  default = "eu-central-1a"
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}

variable "trusted_ip" {
  type    = string
  default = "trusted_ip_address"
}

variable "instance_count" {
  type    = number
  default = 2
}
