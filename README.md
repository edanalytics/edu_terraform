# edu_terraform
This repo contains Terraform/OpenTofu modules for standing up the cloud infrastructure needed to run [EDU](https://enabledataunion.org/) in various platforms. At the moment we focus on the data infrastructure (databases, schemas, warehouses, users, roles, etc.) in Snowflake and Databricks. In the future, we may also support the network and compute infrastructure in AWS.

The code _should_ support both Terraform and OpenTofu. We recommend OpenTofu, as it is fully open-source.

To run this code, you need to
1. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) or [OpenTofu](https://opentofu.org/docs/intro/install/deb/)
1. Set up credentials for your cloud provider - see the instructions for a particular provider in the docs below.
1. Make an infrastructure project directory (say, `edu_infrastructure/`) and `cd` into it.
1. Copy the files from `examples/[platform]/` into your project directory.
1. Review/customize the settings in the `config.tfvars` file.
1. Add any additional resources you want to create, or any 
1. Run `tofu init` to initialize OpenTofu and install the necessary providers.
1. Run `tofu plan -var-file=config.tfvars` to see _what infrastructure would be built_.
1. Run `tofu apply -var-file=config.tfvars` to stand up the infrastructure.
1. Run `tofu destroy -var-file=config.tfvars` to remove everything created by OpenTofu.


## Snowflake configuration

### Credential setup
Set up a `~/.snowflake/config` file with
```bash
# This file contains Snowflake credentials.

[profile_identifier]
organization_name='YOURORGNAME'
account_name='YOURACCOUNT'
user='YOU@YOURDOMAIN.COM'
password='PASSWORD_OR_PAT'
role='ACCOUNTADMIN'
```
(The Snowflake user must be `accountadmin`, i.e., able to `use` the roles `sysadmin`, `securityadmin`, and `useradmin`.)

### Code setup
Copy-modify the code in `examples/snowflake/`.


## Databricks configuration
Coming soon!



## Playbooks
In addition to the default setup that comes with the modules, we also provide some "playbooks" which are optional snippets of TF code you can copy into your project to achieve a specific objective or support some functionality. See the following `playbooks/`:
* [limit access to your Snowflake account from specific IP address ranges](playbooks/snowflake-network-policy.tf)
* ...




## REMOVE !!! AWS (experimental)
Terraform/OpenTofu code for provisioning some of the AWS infrastructure needed for EDU by creating CloudFormation stacks based on the templates in [this repo](https://github.com/edanalytics/edfi_airflow_cloudformation). This is experimental and commented out by default.

Note that some resources must already exist in AWS before you can run this Terraform, namely the

* networking setup (VPC, subnets, elastic IPs, hosted zone, etc.)
* EC2 key pair (for SSHing into the Airflow instance)
* ACM certificate (for serving traffic over SSL from your `aws_domain_name`)
* source S3 bucket (containing the CloudFormation template for the stack and the Lambda functions they deploy)
* datalake S3 bucket (where raw Ed-Fi data will be stored)

### Credential setup
Create an [IAM programmatic user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) with full administrative access

Set up a [named profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) for this user
Activate the profile by running `export AWS_PROFILE=yournamedprofile`

Note that provisioning the AWS infrastructure takes 15-20 minutes.
