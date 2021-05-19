variable "mock_splunk" {
  type    = string
  default = "mock-splunk-instance"
}

variable "instance_size" {
  type    = string
  default = "t3.micro"
}

variable "instance_profile" {}

variable "subnet_id" {}

variable "region" {}

variable "mandatory_tags" {}
