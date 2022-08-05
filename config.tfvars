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


# snowflake_sso_integration = "YES"
# snowflake_sso_integration_key_file = "path/to/credentials/snowflake/key.pem"
# snowflake_sso_integration_callback_url = "https://someschooldistrict.org/saml/sign-in"
# snowflake_allowed_ips = [
#   "192.168.1.0/24"
# ]
# snowflake_blocked_ips = [
#   "192.168.1.99"
# ]




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

edu_snowflake_custom_grants_objects = []

edu_snowflake_custom_grants_roles = []