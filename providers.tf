# Default provider
provider "aws" {
  region = var.region_primary
}

provider "aws" {
  region = "us-west-2"
  alias  = "secondary"
}
