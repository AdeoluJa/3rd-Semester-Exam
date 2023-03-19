terraform {
  backend "s3" {
    bucket  = "adeolu-exam-bucket-v"
    key     = "terraform.tfstate"
    encrypt = true
  }
}


