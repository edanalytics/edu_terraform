# Declare required default and custom configs
variable aws_environment {}
variable aws_domain_name {}
variable aws_hosted_zone_id {}
variable aws_source_bucket {}
variable aws_vpc_id {}
variable aws_public_subnet_1_id {}
variable aws_public_subnet_2_id {}
variable aws_private_subnet_1_id {}
variable aws_private_subnet_2_id {}
variable aws_ec2_key_pair_name {}
variable aws_ec2_size {}
variable aws_ec2_project_repo {}
variable aws_ec2_ssh_github_keys {}
variable aws_ec2_ssl_cert_arn {}
variable aws_datalake_bucket {}
variable aws_rds_password {}

# one module to rule them all! :)
module edu_aws {
  source = "./modules/edu-aws"

  environment         = var.aws_environment
  domain_name         = var.aws_domain_name
  hosted_zone_id      = var.aws_hosted_zone_id
  source_bucket       = var.aws_source_bucket
  vpc_id              = var.aws_vpc_id
  public_subnet_1_id  = var.aws_public_subnet_1_id
  public_subnet_2_id  = var.aws_public_subnet_2_id
  private_subnet_1_id = var.aws_private_subnet_1_id
  private_subnet_2_id = var.aws_private_subnet_2_id
  ec2_key_pair_name   = var.aws_ec2_key_pair_name
  ec2_size            = var.aws_ec2_size
  ec2_project_repo    = var.aws_ec2_project_repo
  ec2_ssh_github_keys = var.aws_ec2_ssh_github_keys
  ec2_ssl_cert_arn    = var.aws_ec2_ssl_cert_arn
  aws_datalake_bucket = var.aws_datalake_bucket
  rds_password        = var.aws_rds_password
}
