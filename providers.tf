# Default provider
provider "aws" {
  region = var.region_primary
}

provider "aws" {
  region = var.region_secondary
  alias  = "aws_secondary"
}
