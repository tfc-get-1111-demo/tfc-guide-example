# Default provider
provider "aws" {
  region = var.region_primary
}

# Secondary provider
provider "aws-secondary" {
  region = var.region_secondary
}
