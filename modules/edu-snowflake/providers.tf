terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
      configuration_aliases = [ snowflake.sysadmin, snowflake.securityadmin, snowflake.useradmin, snowflake.accountadmin ]
    }
  }
}
