module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"
  name    = "my-vpc"
  cidr    = "10.0.0.0/16"
}
