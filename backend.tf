terraform {
  backend "s3" {
    encrypt = true
    bucket  = "bloodbridge-frontend-tfstate-bucket"
    key     = "backend/bloodbridge.tfstate"
    region  = "us-east-1"
    # profile        = "default"
  }
}
