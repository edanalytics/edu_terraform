# SPDX-FileCopyrightText: 2022 Education Analytics
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
      configuration_aliases = [ snowflake.sysadmin, snowflake.securityadmin, snowflake.useradmin, snowflake.accountadmin ]
    }
  }
}
