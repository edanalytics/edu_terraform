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
}
provider snowflake {
  alias  = "useradmin"
  profile = var.snowflake_profile
  role = "useradmin"
}
provider snowflake {
  alias  = "securityadmin"
  profile = var.snowflake_profile
  role = "securityadmin"
}
provider snowflake {
  alias  = "accountadmin"
  profile = var.snowflake_profile
  role = "accountadmin"
}