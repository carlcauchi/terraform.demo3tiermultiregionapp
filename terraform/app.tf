# Create DemoApp
module "app-eu-central-1" {
  source                = "../modules/app"
  vpc_id                = module.vpc-eu-central-1.vpc_id
  public_subnet_az1_id  = module.vpc-eu-central-1.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc-eu-central-1.public_subnet_az2_id
  private_subnet_az1_id = module.vpc-eu-central-1.private_subnet_az1_id
  private_subnet_az2_id = module.vpc-eu-central-1.private_subnet_az2_id
}

module "app-us-east-1" {
  providers = {
    aws = aws.us-east-1
  }
  source                = "../modules/app"
  vpc_id                = module.vpc-us-east-1.vpc_id
  public_subnet_az1_id  = module.vpc-us-east-1.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc-us-east-1.public_subnet_az2_id
  private_subnet_az1_id = module.vpc-us-east-1.private_subnet_az1_id
  private_subnet_az2_id = module.vpc-us-east-1.private_subnet_az2_id
}