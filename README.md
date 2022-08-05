# edu_terraform

This repo contains Terraform code for standing up the infrastructure (databases, schemas, warehouses, users, roles, etc.) in Snowflake for the Ed-Fi data warehouse product. The structure is based on SQL from [this repo](https://github.com/edanalytics/snowflake_init).

In the future, we may also add the AWS infrastructure (currently provisioned via CloudFormation templates from [here](https://github.com/edanalytics/edfi_airflow_cloudformation/tree/master/templates)) with Terraform instead.

To run the code locally:
1. Set up a file such as `~/.snowflake/credentials-account.env` with

    ```bash
    export SNOWFLAKE_ACCOUNT='someaccount'
    export SNOWFLAKE_USER="someuser"
    export SNOWFLAKE_PASSWORD='somepassword'
    export SNOWFLAKE_REGION=''
    export SNOWFLAKE_ROLE='sysadmin'
   ```
   The Snowflake user must be `accountadmin`, i.e., able to `use` the roles `sysadmin`, `securityadmin`, and `useradmin`.
2. Activate the credentials by running `source ~/.snowflake/credentials-test.env`
3. In this repo, run `terraform apply -var-file=config.tfvars` to stand up the infrastructure.
4. Run `terraform destroy -var-file=config.tfvars` to remove everything.

Base resource definitions are defined in `terraform.tfvars`; customizations you might want to do for a specific implementation should go in `config.tfvars`.