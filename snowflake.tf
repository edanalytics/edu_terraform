# This Terraform file creates the Snowflake infrastructure required for the EDU Ed-Fi data warehouse

# Before running it, you need to `source ~/.snowflake/creds.env` where `~/.snowflake/creds.env` is
# a file that exports the environment variables SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD,
# SNOWFLAKE_REGION, SNOWFLAKE_ROLE, and any others required for to make a Snowflake connection: see
# https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs

# You should probably also review/customize the configuration variables in `config.tfvars`


# Declare required default and custom configs
variable edu_snowflake_default_databases {}
variable edu_snowflake_custom_databases {}
variable edu_snowflake_default_schemas {}
variable edu_snowflake_custom_schemas {}
variable edu_snowflake_default_tables_template {}
variable edu_snowflake_default_tables_change_version {}
variable edu_snowflake_default_file_formats {}
variable edu_snowflake_custom_file_formats {}
variable edu_snowflake_default_warehouses {}
variable edu_snowflake_custom_warehouses {}
variable edu_snowflake_default_roles {}
variable edu_snowflake_custom_roles {}
variable edu_snowflake_default_users {}
variable edu_snowflake_custom_users {}
variable edu_snowflake_default_grants_objects {}
variable edu_snowflake_custom_grants_objects {}
variable edu_snowflake_default_grants_roles {}
variable edu_snowflake_custom_grants_roles {}

# Concatenate defaults and customs into a single list
locals {
  databases = concat(var.edu_snowflake_default_databases, var.edu_snowflake_custom_databases)
  schemas = concat(var.edu_snowflake_default_schemas, var.edu_snowflake_custom_schemas)
  tables_template = var.edu_snowflake_default_tables_template
  tables_change_version = var.edu_snowflake_default_tables_change_version
  file_formats = concat(var.edu_snowflake_default_file_formats, var.edu_snowflake_custom_file_formats)
  warehouses = concat(var.edu_snowflake_default_warehouses, var.edu_snowflake_custom_warehouses)
  roles = concat(var.edu_snowflake_default_roles, var.edu_snowflake_custom_roles)
  users = concat(var.edu_snowflake_default_users, var.edu_snowflake_custom_users)
  grants_objects = concat(var.edu_snowflake_default_grants_objects, var.edu_snowflake_custom_grants_objects)
  grants_roles = concat(var.edu_snowflake_default_grants_roles, var.edu_snowflake_custom_grants_roles)
}

# one module to rule them all! :)
module edu_snowflake {
  source = "./modules/edu-snowflake"

  databases = local.databases
  schemas = local.schemas
  tables_template = local.tables_template
  tables_change_version = local.tables_change_version
  file_formats = local.file_formats
  warehouses = local.warehouses
  roles = local.roles
  users = local.users
  grants_objects = local.grants_objects
  grants_roles = local.grants_roles
}
