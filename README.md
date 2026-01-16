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
