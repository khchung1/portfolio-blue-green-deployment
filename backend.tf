terraform {

  required_version = ">= 1.9.0"
  backend "s3" {
    bucket = "sctp-ce6-tfstate"                # Terraform State bucket name
    key    = "KokHui-bluegreen-deploy.tfstate" # Name of your tfstate file
    region = "ap-southeast-1"                  # Terraform State bucket region

  }
}