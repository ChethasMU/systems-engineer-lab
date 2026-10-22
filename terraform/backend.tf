terraform {
  backend "s3" {
    bucket       = "chethas-tfstate-1792690322"
    key          = "deepdive/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}