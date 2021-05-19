# Default provider
provider "aws" {
  region  = var.region_primary
}

provider "aws" {
  region = var.region_secondary
  alias  = "secondary"
}

module "hashi-demo" {
  source          = "./modules/mock-splunk"
  region          = var.region_secondary
  mock_splunk     = var.mock_splunk
  instance_size   = var.instance_size
  subnet_id       = module.hashi-demo-vpc.public_subnets[0]
  mandatory_tags  = var.mandatory_tags
}

module "hashi-demo-secondary" {
  source          = "./modules/mock-splunk"
  region          = var.region_secondary
  mock_splunk     = var.mock_splunk
  instance_size   = var.instance_size
  subnet_id       = module.hashi-demo-vpc-secondary.public_subnets[0]
  mandatory_tags  = var.mandatory_tags
}
