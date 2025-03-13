module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "1.0.0"
  name    = "my-vpc"
  cidr    = "10.0.0.0/16"
}
