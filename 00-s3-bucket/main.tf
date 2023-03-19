provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "adeolu-exam-bucket-v"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Terraform = "true"
  }
}
