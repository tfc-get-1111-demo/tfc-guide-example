# Default provider
provider "aws" {
  region = var.region_primary
}

provider "aws" {
  region = "us-west-2"
  alias  = "secondary"
}

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.28.0"
#       configuration_aliases = [ aws.secondary ]
#     }
#   }

#   required_version = ">= 0.14.0"
# }