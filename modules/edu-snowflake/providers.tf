terraform {
  required_providers {
    snowflake = {
      source = "snowflake-labs/snowflake"
      version = "2.12.0"
      configuration_aliases = [ snowflake.sysadmin, snowflake.securityadmin, snowflake.useradmin, snowflake.accountadmin ]
    }
  }
}
provider snowflake {
  alias  = "sysadmin"
  profile = var.snowflake_profile
  role = "sysadmin"
  preview_features_enabled = ["snowflake_table_resource", "snowflake_file_format_resource", "snowflake_network_rule_resource"]
}
provider snowflake {
  alias  = "useradmin"
  profile = var.snowflake_profile
  role = "useradmin"
  preview_features_enabled = ["snowflake_table_resource", "snowflake_file_format_resource", "snowflake_network_rule_resource"]
}
provider snowflake {
  alias  = "securityadmin"
  profile = var.snowflake_profile
  role = "securityadmin"
  preview_features_enabled = ["snowflake_table_resource", "snowflake_file_format_resource", "snowflake_network_rule_resource"]
}
provider snowflake {
  alias  = "accountadmin"
  profile = var.snowflake_profile
  role = "accountadmin"
  preview_features_enabled = ["snowflake_table_resource", "snowflake_file_format_resource", "snowflake_network_rule_resource"]
}