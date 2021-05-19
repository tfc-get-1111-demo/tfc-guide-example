variable "mock_splunk" {
  type    = string
  default = "mock-splunk-instance"
}

variable "instance_size" {
  type    = string
  default = "t3.micro"
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

variable "account_id" {
  description = "The AWS ID of the account"
}

# VPC Variables
variable "cidr_primary" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "10.0.0.0/16"
}

variable "azs_primary" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "cidr_secondary" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "10.1.0.0/16"
}

variable "azs_secondary" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "tgw_cidr_size" {
  default     = 28
  description = "size of subnets for transit gateway"
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "enable_s3_endpoint" {
  description = "Configure an S3 Endpoint on the VPC"
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Configure a DynamoDB Endpoint on the VPC"
  default     = false
}

variable "enable_session_manager_endpoints" {
  description = "Configure Session Manager Endpoints on the VPC"
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block"
  default     = false
}
