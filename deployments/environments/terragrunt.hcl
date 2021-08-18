remote_state {
  backend = "s3"
  config = {
    bucket         = "sf-techtest-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "sf-techtest-tf-lock-table"
    role_arn       = "arn:aws:iam::133002017424:role/Terraform"
  }
}

# These are highest level inputs, they will be merged with lower inputs, and
# overridden if needed
inputs = {
  aws_region            = "eu-west-1"
}
