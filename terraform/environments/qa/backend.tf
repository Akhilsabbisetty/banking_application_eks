terraform {
  backend "s3" {
    bucket       = "banking-platform-tfstate-<YOUR_ACCOUNT_ID>"
    key          = "qa/networking.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
