# # set the AWS region to use - you can change this, but then the AMI
# # below will have to change as well (since AMIs are region-specific)
provider "aws" {
  region = "us-east-1"
}

# # we want a micro EC2 instance!
# resource "aws_instance" "app_server" {
#   ami           = "ami-0b59bfac6be064b78"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "ExampleAppServerInstance"
#   }
# }

# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack
# and https://www.terraform.io/language/functions/file

# In order to use this, you need to have
# - a domain pointed at / delegated to the AWS account
# - a VPC in which to build the environment
# - 2 public and 2 private subnets in the VPC
# - a KMS key pair (which you'll use to SSH to the Airflow instance)
# - an ACM certificate (which will be used to server HTTPS traffic from the Airflow instance)
# - an S3 bucket with the CF templates and Lambdas uploaded
resource "aws_cloudformation_stack" "master" {
  name = "${var.environment}-master-stack"
  parameters = {
    # Environment
    EnvLabel = "${var.environment}-airflow-dev"
    S3SourceBucket = "${var.source_bucket}"

    # Network
    DomainName = "${var.domain_name}"
    HostedZoneId = "${var.hosted_zone_id}"
    VPCID = "${var.vpc_id}"
    PublicSubnet1ID = "${var.public_subnet_1_id}"
    PublicSubnet2ID = "${var.public_subnet_2_id}"
    PrivateSubnet1ID = "${var.private_subnet_1_id}"
    PrivateSubnet2ID = "${var.private_subnet_2_id}"
    UpdateRoute53 = "yes"
    AccountType = "Private"
    
    # Data Lake (S3)
    DeployS3Datalake = "No"
    ExistingS3DatalakeBucketName = "${var.aws_datalake_bucket}"
    
    # Airflow instance
    LatestAmiId = "/aws/service/canonical/ubuntu/server/focal/stable/current/amd64/hvm/ebs-gp2/ami-id"
    EnvironmentSize	= "${var.ec2_size}"
    KeyPairName	= "${var.ec2_key_pair_name}"
    ProjectRepoName = "${var.ec2_project_repo}"
    SSHCIDR = "172.102.6.120/29"
    SSHGitHubKeys = "${var.ec2_ssh_github_keys}"
    SSLCertificateId = "${var.ec2_ssl_cert_arn}"
    
    # Airflow RDS instance
    DatabasePassword = "${var.rds_password}"
    PostgresVersion = "Twelve"
  }
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  template_body = "${file("cloud-formation-templates/edfi-airflow-master-existing-vpc.yml")}"
}
# TagReminder	Key: edfi_airflow_access Value: allow	-

# resource "aws_cloudformation_stack" "lambda" {
#   name = "lambda-stack"
#   parameters = {
#     EnvLabel = "gwinnett-airflow-dev"
#     S3BucketSourceCode = "edfi-airflow-cloudformation-gwinnett-dev"
#     S3KeySourceCode = "lambdas"
#   }
#   template_body = "${file("cloud-formation-template/edfi-airflow-master-existing-vpc.yml")}"
# }

# resource "aws_cloudformation_stack" "security" {
#   name = "security-stack"
#   parameters = {
#     EnvLabel = "gwinnett-airflow-dev"
#     S3BucketSourceCode = "edfi-airflow-cloudformation-gwinnett-dev"
#     DeployS3Datalake = "Yes"
#     ExistingS3DatalakeBucketName = ""
#     SSHCIDR = "172.102.6.120/29"
#     SSHGitHubKeys = "ea-mtenhoor ejoranlienea jayckaiser tomreitz jordanmader13"
#     SsmParamStoreLambdaFunctionArn = "arn:aws:lambda:us-east-2:340448183758:function:edfi-airflow-ssm-param-store-gwinnett-airflow-dev"
#     VPCID = "vpc-0664ca5f501967765"
#   }
#   template_body = "${file("cloud-formation-template/edfi-airflow-master-existing-vpc.yml")}"
# }

# resource "aws_cloudformation_stack" "database" {
#   name = "database-stack"
#   parameters = {
#     DBEngineVersion = "12.10"
#     DBInstanceClass = "db.t4g.micro"
#     DBPassword = ""
#     DBUsername = "postgres"
#     EnvLabel = "gwinnett-airflow-dev"
#     KmsKeyId = "7cf47a76-adfc-470d-ba8f-b194a43719a4"
#     ParameterGroupFamily = "postgres12"
#     PrivateSubnet1ID = "subnet-0684d5f9e048a44a7"
#     PrivateSubnet2ID = "subnet-00e46b4ce9e409a41"
#     RDSOptionGroup = "none"
#     RDSSecurityGroupID = "sg-01031ef025d15c11a"
#     SQLEngineEdition = "postgres"
#     SsmParamStoreLambdaFunctionArn = "arn:aws:lambda:us-east-2:340448183758:function:edfi-airflow-ssm-param-store-gwinnett-airflow-dev"
#     VPCID = "vpc-0664ca5f501967765"
#     VolumeSize = "20"
#   }
#   template_body = "${file("cloud-formation-template/edfi-airflow-master-existing-vpc.yml")}"
# }

# resource "aws_cloudformation_stack" "airflow" {
#   name = "airflow-stack"
#   parameters = {
#     ALBSecurityGroup = "sg-0b0fa101896492b44"
#     AirflowInstanceProfile = "arn:aws:iam::340448183758:instance-profile/gwinnett-airflow-dev-IamKmsSecurityGroupsStack-15Y077V7M5Y7P-AirflowServerIamInstanceProfile-k6hGRzmyxdot"
#     AirflowInstanceRole = "arn:aws:iam::340448183758:role/gwinnett-airflow-dev-IamKmsSe-AirflowServerIamRole-ILXJ5QYCB1SH"
#     AirflowServerEipAddress = "3.13.167.107"
#     AirflowServerEipAllocationId = "eipalloc-080ec9716594a2025"
#     CloudwatchLogGroupARN = "arn:aws:logs:us-east-2:340448183758:log-group:edfi-airflow-remote-logging-gwinnett-airflow-dev:*"
#     DatabasePassword = "****"
#     DomainName = "airflow-dev.gwinnett.edanalytics.org"
#     EfsSecurityGroup = "sg-0e80a91226a4bdc3d"
#     EnvLabel = "gwinnett-airflow-dev"
#     InstanceType = "t3a.large"
#     KeyPairName = "Gwinnett-us-east-2"
#     KmsKeyId = "7cf47a76-adfc-470d-ba8f-b194a43719a4"
#     LatestAmiId = "ami-07f84a50d2dec2fa4"
#     ProjectRepoName = "edfi_dw_gwinnett"
#     PublicSubnet1ID = "subnet-020cb28ed4e1dbdd3"
#     PublicSubnet2ID = "subnet-02fd08cdb78281e9e"
#     RDSEndpoint = "edfi-airflow-gwinnett-airflow-dev.csrmkhz61mmh.us-east-2.rds.amazonaws.com"
#     S3SourceBucket = "edfi-airflow-cloudformation-gwinnett-dev"
#     SSLCertificateId = "arn:aws:acm:us-east-2:340448183758:certificate/b7efc5d0-d299-4baf-a902-39f5d73ff75f"
#     SecurityGroup = "sg-070b4ae8c3c2ee97e"
#     VPCID = "vpc-0664ca5f501967765"
#   }
#   template_body = "${file("cloud-formation-template/edfi-airflow-master-existing-vpc.yml")}"
# }


# Currently, the following needs to be already set up (manually) in AWS before
# you can run the CloudFormation template:
# - S3 bucket with Lambda scripts and CF templates
# - VPC, subnets, elastic IPs, security group(s)
# - KMS key
# - SSL certificate for Airflow
# - SSM/ParamStore values for GitHub key(s)
# - CloudWatch LogGroup
# Then you can run the CF template (which requires a bunch more inputs)


# It would be nice to fully automate this and reduce inputs to:
# 
# Parameters/Inputs:
# - AWS region in which to create VPC and networking (e.g. us-east-2)
# - top-level domain (which the AWS account can control) e.g. (gwinnett.stadium.com)
# - Airflow EC2 instance class/size (e.g. medium)
# - Airflow RDS Postgres instance class/size (e.g. small)
# - Project repo name (e.g. edu_application_gwinnett)
# - SSM/ParamStore values for GitHub key(s) (so project repo can be cloned onto Airflow server)

# Outputs:
# - IP address + URL of Airflow server? (one for each environment e.g. airflow-prod.gwinnett.stadium.com)
# - URL of dbt-docs site (e.g. dbt-docs.gwinnett.stadium.com)
# - KMS KeyPair created?
# - Snowflake / Airflow user passwords stored in SSM/ParamStore
# - ARN of CloudWatch LogGroup created

# Things that could be added to infrastructure provisioning/setup:
# - create Cognito pool/Lambdas to put dbt-docs site behind a login if enabled
#   - create Cognito users for custom list of Snowflake and/or Airflow users (these could be managed by Terraform)
# - create Airflow users and connections
