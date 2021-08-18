# Configure network
module "network" {
  source = "../network"

  az_count   = 2
  cidr_block = "17.7.0.0/16"

  providers = {
    aws = aws
  }
}
