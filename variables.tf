variable "mock_splunk" {
  type    = string
  default = "mock-splunk-instance"
}

variable "instance_size" {
  type    = string
  default = "t3.micro"
}

variable "instance_ami" {
  type    = string
  default = "ami-09e67e426f25ce0d7" #Ubuntu latest USE1
}

variable "region_primary" {
  type    = string
  default = "us-east-1"
}

variable "region_secondary" {
  type    = string
  default = "us-west-2"
}

variable "mandatory_tags" {}
