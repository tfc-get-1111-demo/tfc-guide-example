####
# This calculates the subnet IP space based on the CIDR values passed for the
# sandbox account
####

locals {
  # define vpc cidr block
  public_cidr  = cidrsubnet(var.cidr_primary, 1, 0)
  private_cidr = cidrsubnet(var.cidr_primary, 1, 1)

  # add some logic to get cidr size and tgw size
  cidr_size        = split("/", split(".", local.private_cidr)[3])[1]
  tgw_cidr_size    = var.tgw_cidr_size
  tgw_differential = local.tgw_cidr_size - local.cidr_size

  # define all public subnets and their cidr ranges
  public_subnets = {
    "web-a" = {
      cidr_block              = cidrsubnet(local.public_cidr, 2, 0)
      availability_zone_index = 0
    },
    "web-b" = {
      cidr_block              = cidrsubnet(local.public_cidr, 2, 1)
      availability_zone_index = 1
    },
    "web-c" = {
      cidr_block              = cidrsubnet(local.public_cidr, 2, 2)
      availability_zone_index = 2
    },
    "spare_public" = {
      cidr_block              = cidrsubnet(local.public_cidr, 2, 3)
      availability_zone_index = 0
    }
  }

  # define all private subnets and their cidr ranges
  private_subnets = {
    "app-a" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 0)
      availability_zone_index = 0
    },
    "app-b" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 1)
      availability_zone_index = 1
    },
    "app-c" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 2)
      availability_zone_index = 2
    },
    "db-a" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 3)
      availability_zone_index = 0
    },
    "db-b" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 4)
      availability_zone_index = 1
    },
    "db-c" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 5)
      availability_zone_index = 2
    },
    "svc-a" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 6)
      availability_zone_index = 0
      interface_endpoint      = true
    },
    "svc-b" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 7)
      availability_zone_index = 1
      interface_endpoint      = true
    },
    "svc-c" = {
      cidr_block              = cidrsubnet(local.private_cidr, 4, 8)
      availability_zone_index = 2
      interface_endpoint      = true
    },
    "tgw-a" = {
      cidr_block              = cidrsubnet(local.private_cidr, local.tgw_differential, pow(2, local.tgw_differential) - 3)
      availability_zone_index = 0
    },
    "tgw-b" = {
      cidr_block              = cidrsubnet(local.private_cidr, local.tgw_differential, pow(2, local.tgw_differential) - 2)
      availability_zone_index = 1
    },
    "tgw-c" = {
      cidr_block              = cidrsubnet(local.private_cidr, local.tgw_differential, pow(2, local.tgw_differential) - 1)
      availability_zone_index = 2
    }
  }
  interface_endpoint_subnets = [for key, subnet in local.private_subnets : key if contains(keys(subnet), "interface_endpoint")]
}

module "hashi-demo-vpc" {
  source                                  = "github.com/tfc-get-1111-demo/terraform-aws-vpc.git"
  name                                    = "vpc"
  cidr                                    = var.cidr_primary
  azs                                     = var.azs_primary
  public_subnets                          = local.public_subnets
  private_subnets                         = local.private_subnets
  enable_nat_gateway                      = var.enable_nat_gateway
  single_nat_gateway                      = var.single_nat_gateway
  enable_s3_endpoint                      = var.enable_s3_endpoint
  enable_dynamodb_endpoint                = var.enable_dynamodb_endpoint
  assign_generated_ipv6_cidr_block        = var.assign_generated_ipv6_cidr_block
  interface_endpoint_subnets              = local.interface_endpoint_subnets
  enable_session_manager_endpoints        = var.enable_session_manager_endpoints
  flowlog_format                          = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${tcp-flags} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
  tags                                    = var.mandatory_tags
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.hashi-demo-vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnets in VPC"
  value       = module.hashi-demo-vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnets in VPC"
  value       = module.hashi-demo-vpc.private_subnets
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.hashi-demo-vpc.nat_public_ips
}

# Secondary Region resources

####
# This calculates the subnet IP space based on the CIDR values passed for the
# sandbox account
####

locals {
  # define vpc cidr block
  public_cidr_secondary  = cidrsubnet(var.cidr_secondary, 1, 0)
  private_cidr_secondary = cidrsubnet(var.cidr_secondary, 1, 1)

  # add some logic to get cidr size and tgw size
  cidr_size_secondary        = split("/", split(".", local.private_cidr_secondary)[3])[1]
  tgw_cidr_size_secondary    = var.tgw_cidr_size
  tgw_differential_secondary = local.tgw_cidr_size - local.cidr_size

  # define all public subnets and their cidr ranges
  public_subnets_secondary = {
    "web-a" = {
      cidr_block              = cidrsubnet(local.public_cidr_secondary, 2, 0)
      availability_zone_index = 0
    },
    "web-b" = {
      cidr_block              = cidrsubnet(local.public_cidr_secondary, 2, 1)
      availability_zone_index = 1
    },
    "web-c" = {
      cidr_block              = cidrsubnet(local.public_cidr_secondary, 2, 2)
      availability_zone_index = 2
    },
    "spare_public" = {
      cidr_block              = cidrsubnet(local.public_cidr_secondary, 2, 3)
      availability_zone_index = 0
    }
  }

  # define all private subnets and their cidr ranges
  private_subnets_secondary = {
    "app-a" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 0)
      availability_zone_index = 0
    },
    "app-b" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 1)
      availability_zone_index = 1
    },
    "app-c" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 2)
      availability_zone_index = 2
    },
    "db-a" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 3)
      availability_zone_index = 0
    },
    "db-b" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 4)
      availability_zone_index = 1
    },
    "db-c" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 5)
      availability_zone_index = 2
    },
    "svc-a" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 6)
      availability_zone_index = 0
      interface_endpoint      = true
    },
    "svc-b" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 7)
      availability_zone_index = 1
      interface_endpoint      = true
    },
    "svc-c" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, 4, 8)
      availability_zone_index = 2
      interface_endpoint      = true
    },
    "tgw-a" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, local.tgw_differential, pow(2, local.tgw_differential) - 3)
      availability_zone_index = 0
    },
    "tgw-b" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, local.tgw_differential, pow(2, local.tgw_differential) - 2)
      availability_zone_index = 1
    },
    "tgw-c" = {
      cidr_block              = cidrsubnet(local.private_cidr_secondary, local.tgw_differential, pow(2, local.tgw_differential) - 1)
      availability_zone_index = 2
    }
  }
  interface_endpoint_subnets_secondary = [for key, subnet in local.private_subnets_secondary : key if contains(keys(subnet), "interface_endpoint")]
}

module "hashi-demo-vpc-secondary" {
  source                                  = "github.com/tfc-get-1111-demo/terraform-aws-vpc.git"
  name                                    = "vpc"
  cidr                                    = var.cidr_secondary
  azs                                     = var.azs_secondary
  public_subnets                          = local.public_subnets_secondary
  private_subnets                         = local.private_subnets_secondary
  enable_nat_gateway                      = var.enable_nat_gateway
  single_nat_gateway                      = var.single_nat_gateway
  enable_s3_endpoint                      = var.enable_s3_endpoint
  enable_dynamodb_endpoint                = var.enable_dynamodb_endpoint
  assign_generated_ipv6_cidr_block        = var.assign_generated_ipv6_cidr_block
  interface_endpoint_subnets              = local.interface_endpoint_subnets
  enable_session_manager_endpoints        = var.enable_session_manager_endpoints
  flowlog_format                          = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${tcp-flags} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"
  tags                                    = var.mandatory_tags
}

output "vpc_id_secondary" {
  description = "The ID of the VPC"
  value       = module.hashi-demo-vpc-secondary.vpc_id
}

output "public_subnets_secondary" {
  description = "List of public subnets in VPC"
  value       = module.hashi-demo-vpc-secondary.public_subnets
}

output "private_subnets_secondary" {
  description = "List of private subnets in VPC"
  value       = module.hashi-demo-vpc-secondary.private_subnets
}

# NAT gateways
output "nat_public_ips_secondary" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.hashi-demo-vpc-secondary.nat_public_ips
}
