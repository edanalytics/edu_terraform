resource snowflake_database security_database {
  provider = snowflake.sysadmin
  # NOTE about the use of `upper()`
  name     = upper("security")
}

resource snowflake_schema security_util_schema {
  provider = snowflake.sysadmin
  name     = upper("util")
  database = upper("security")
  depends_on   = [ snowflake_database.security_database ]
}

# Multiple network rules are possible (list them all in the network policy's `allowed_network_rule_list`)
resource "snowflake_network_rule" "my_office_vpn_rule" {
  provider   = snowflake.accountadmin
  name       = "my_office_vpn"
  database   = "security"
  schema     = "util"
  type       = "IPV4"
  mode       = "INGRESS"
  value_list = ["999.999.999.999/24"] # CIDR notation
  depends_on = [ snowflake_schema.security_util_schema ]
}

resource "snowflake_network_policy" "network_allow_list" {
  provider                  = snowflake.accountadmin
  name                      = "allow_list"
  allowed_network_rule_list = [ snowflake_network_rule.my_office_vpn_rule.fully_qualified_name ]
}

resource "snowflake_current_account" "my_account" {
  provider = snowflake.accountadmin
  allow_client_mfa_caching = true
  allow_id_token = true
  network_policy = snowflake_network_policy.network_allow_list.fully_qualified_name
}
