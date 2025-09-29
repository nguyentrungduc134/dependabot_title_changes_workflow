module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.3.0"
  name    = "my-vpc"
  cidr    = "10.0.0.0/16"
}
