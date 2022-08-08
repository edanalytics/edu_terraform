# Add your custom Snowflake resources here

# At least one environment "prod" is required. You can add others for testing as needed.
environments = [
  {
    name = "prod"
    prefix = ""
    postfix = ""
    aws_airflow_instance_size = "large"
    aws_airflow_instance_branch = "main"
  },
  {
    name = "dev"
    prefix = "dev_"
    postfix = "_dev"
    aws_airflow_instance_size = "small"
    aws_airflow_instance_branch = "dev"
  }
]

tenants = [
  # # for multi-tenant steups:
  # "tenant1",
  # "tenant2"
  # # (this could result in a database and roles being created for each tenant?)
  # # (e.g. database `raw_tenant1_db` and role `db_raw_tenant1_rw`)
]



# -----------------------------------------------------------------------------
# Security policies, integrations, and federated auth with an IdP



# Uncomment and customize the following block for OAuth integration:

# see https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/oauth_integration
# resource "snowflake_oauth_integration" "tableau_desktop" {
#   name                         = "TABLEAU_DESKTOP"
#   oauth_client                 = "TABLEAU_DESKTOP"
#   enabled                      = true
#   oauth_issue_refresh_tokens   = true
#   oauth_refresh_token_validity = 3600
#   blocked_roles_list           = ["SYSADMIN"]
# }



# Uncomment and customize the following block for SAML SSO:

# see https://docs.snowflake.com/en/user-guide/admin-security-fed-auth.html
# and https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/saml_integration
# resource "snowflake_saml_integration" "some_school_district_saml_integration" {
#   name = "some_school_district_saml_integration"
#   saml2_provider = "CUSTOM"
#   saml2_issuer = "https://sts.windows.net/long-hexa-decim-alst-ring-likethis12"
#   saml2_sso_url = "https://login.microsoftonline.com/long-hexa-decim-alst-ring-likethis12/saml2"
#   saml2_snowflake_acs_url = 'https://someschooldistrict.snowflakecomputing.com/fed/login';
#   saml2_snowflake_issuer_url = 'https://someschooldistrict.snowflakecomputing.com';
#   # DO NOT put your raw cert here and commit it to GitHub! instead, place it in the env var TF_VAR_sso_cert in your environment file
#   saml2_x509_cert = "${sso_cert}" # Base64 encoded IdP signing certificate on a single line without BEGIN CERTIFICATE header or END CERTIFICATE footer
#   enabled = true
# }



# Uncomment and customize the following block for a custom network policy (to restrict Snowflake access):

# see https://docs.snowflake.com/en/user-guide/network-policies.html
# and https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/network_policy
# resource snowflake_network_policy policy {
#   name    = "policy"
#   comment = "A policy."

#   allowed_ip_list = ["192.168.0.100/24"]
#   blocked_ip_list = ["192.168.0.101"]
# }



edu_snowflake_custom_databases = [
  # {
  #   name    = "bus_data"
  #   comment = ""
  # },
]

edu_snowflake_custom_schemas = [
  # {
  #   database = "some_db"
  #   name     = "new_schema_name"
  #   comment  = "Description of what this schema is for"
  # },
]

# custom tables should be added to `snowflake-tables.tf` (instead of here)

edu_snowflake_custom_file_formats = [
  # {
  #   database           = "some_db"
  #   schema             = "some_schema"
  #   name               = "json_default"
  #   type               = "json"
  #   compression        = "auto"
  #   enable_octal       = false
  #   allow_duplicate    = false
  #   strip_outer_array  = false 
  #   strip_null_values  = true 
  #   ignore_utf8_errors = false
  # },
]

edu_snowflake_custom_warehouses = [
  # {
  #   name                = "querying_warehouse"
  #   size                = "xsmall"
  #   auto_suspend        = 60
  #   auto_resume         = true
  #   initially_suspended = true
  #   comment             = "Ad-hoc queries"
  # },
]

edu_snowflake_custom_roles = [
  # {
  #   name    = "custom_role_1"
  #   comment = "Access role: description of the purpose of this role"
  # },
]

edu_snowflake_custom_users = [
  {
    name              = "ally.doe@someschool.org"
    # username          = "ally.doe@someschool.org"
    # email             = "ally.doe@someschool.org"
    default_warehouse = "ea_ad_hoc"
    default_namespace = "analytics"
    roles             = [ "district_analyst" ]
    default_role      = "district_analyst"
    comment           = "User account for Ally Doe"
  },
  {
    name              = "bill.smith@someschool.org"
    # username          = "bill.smith@someschool.org"
    # email             = "bill.smith@someschool.org"
    default_warehouse = "ea_ad_hoc"
    default_namespace = "analytics"
    roles             = [ "district_analyst" ]
    default_role      = "district_analyst"
    comment           = "User account for Bill Smith"
  },
  {
    name              = "treitz@edanalytics.org"
    # username          = "treitz@edanalytics.org"
    # email             = "treitz@edanalytics.org"
    default_warehouse = "ea_ad_hoc"
    default_namespace = "analytics"
    roles             = [ "ea_read" ]
    default_role      = "ea_read"
    comment           = "User account for Tom Reitz"
  }
]

edu_snowflake_custom_grants_objects = [
  # {
  #   privileges             = [ "usage" ]
  #   on_object_type         = "DATABASE | SCHEMA | TABLE | VIEW | STAGE | FILE FORMAT | WAREHOUSE"
  #   on_object_names        = [ "object_name" ]
  #   in_parent_object_type  = " | DATABASE | DATABASE.SCHEMA"
  #   in_parent_object_name  = "parent_object_name"
  #   on_future              = false | true
  #   to_role_names          = [ "role_name" ]
  # },
]

edu_snowflake_custom_grants_roles = [
  # {
  #   role_names      = [ "role_name" ] # to
  #   to_object_type  = "ROLE | USER"
  #   to_object_names = [ "to_object_name" ]
  # },
]
