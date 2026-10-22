provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "deepdive"
      ManagedBy = "terraform"
    }
  }
}
