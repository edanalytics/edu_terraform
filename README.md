# edu_terraform

This repo contains Terraform code for standing up the infrastructure (databases, schemas, warehouses, users, roles, etc.) in Snowflake for the Ed-Fi data warehouse product. The structure is based on SQL from [this repo](https://github.com/edanalytics/snowflake_init). This Terraform also provisions the AWS infrastructure needed by creating CloudFormation stacks based on the templates in [this repo](https://github.com/edanalytics/edfi_airflow_cloudformation).

Note that some resources must already exist in AWS before you can run this Terraform, namely the

* networking setup (VPC, subnets, elastic IPs, hosted zone, etc.)
* EC2 key pair (for SSHing into the Airflow instance)
* ACM certificate (for serving traffic over SSL from your `aws_domain_name`)
* source S3 bucket (containing the CloudFormation template for the stack and the Lambda functions they deploy)
* datalake S3 bucket (where raw Ed-Fi data will be stored)


To run the code locally:
1. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
1. Set up your Snowflake credentials:
    1. Set up a file such as `~/.snowflake/credentials-account.env` with

        ```bash
            export SNOWFLAKE_ACCOUNT='someaccount'
            export SNOWFLAKE_USER="someuser"
            export SNOWFLAKE_PASSWORD='somepassword'
            export SNOWFLAKE_REGION=''
            export SNOWFLAKE_ROLE='sysadmin'
        ```
        The Snowflake user must be `accountadmin`, i.e., able to `use` the roles `sysadmin`, `securityadmin`, and `useradmin`.
    1. Activate the credentials by running `source ~/.snowflake/credentials-test.env`
1. Set up your AWS credentials:
    1. Create an [IAM programmatic user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) with full administrative access
    1. Set up a [named profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) for this user
    1. Activate the profile by running `export AWS_PROFILE=yournamedprofile`
1. In this repo, review/customize the settings in the `config.tfvars` file.
1. Run `terraform apply -var-file=config.tfvars` to stand up the infrastructure.
1. Run `terraform destroy -var-file=config.tfvars` to remove everything.

Note that provisioning the AWS infrastructure takes 15-20 minutes.

Base resource definitions are defined in `terraform.tfvars`; customizations you might want to do for a specific implementation should go in `config.tfvars`.
