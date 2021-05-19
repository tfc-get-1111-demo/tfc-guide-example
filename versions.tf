terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.28.0"
      configuration_aliases = [ secondary ]
    }
  }

  required_version = ">= 0.14.0"
}