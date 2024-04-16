# Create VPC
module "vpc-eu-central-1" {
  source                  = "../modules/vpc"
  region                  = "eu-central-1"
  project_name            = "demo3tiermultiregionapp"
  vpc_cidr                = "10.0.0.0/16"
  public_subnet_az1_cidr  = "10.0.0.0/24"
  public_subnet_az2_cidr  = "10.0.1.0/24"
  private_subnet_az1_cidr = "10.0.2.0/24"
  private_subnet_az2_cidr = "10.0.3.0/24"
}

# Create NAT gateway
module "nat-gateway-eu-central-1" {
  source                = "../modules/nat-gateway"
  public_subnet_az1_id  = module.vpc-eu-central-1.public_subnet_az1_id
  internet_gateway      = module.vpc-eu-central-1.internet_gateway
  public_subnet_az2_id  = module.vpc-eu-central-1.public_subnet_az2_id
  vpc_id                = module.vpc-eu-central-1.vpc_id
  private_subnet_az1_id = module.vpc-eu-central-1.private_subnet_az1_id
  private_subnet_az2_id = module.vpc-eu-central-1.private_subnet_az2_id
}

# Create VPC
module "vpc-us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source                  = "../modules/vpc"
  region                  = "us-east-1"
  project_name            = "demo3tiermultiregionapp"
  vpc_cidr                = "10.1.0.0/16"
  public_subnet_az1_cidr  = "10.1.0.0/24"
  public_subnet_az2_cidr  = "10.1.1.0/24"
  private_subnet_az1_cidr = "10.1.2.0/24"
  private_subnet_az2_cidr = "10.1.3.0/24"
}

# Create NAT gateway
module "nat-gateway-us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source                = "../modules/nat-gateway"
  public_subnet_az1_id  = module.vpc-us-east-1.public_subnet_az1_id
  internet_gateway      = module.vpc-us-east-1.internet_gateway
  public_subnet_az2_id  = module.vpc-us-east-1.public_subnet_az2_id
  vpc_id                = module.vpc-us-east-1.vpc_id
  private_subnet_az1_id = module.vpc-us-east-1.private_subnet_az1_id
  private_subnet_az2_id = module.vpc-us-east-1.private_subnet_az2_id
}