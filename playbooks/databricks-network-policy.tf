# SPDX-FileCopyrightText: 2022 Education Analytics
# SPDX-License-Identifier: MPL-2.0

resource databricks_workspace_conf this {
  provider      = databricks.workspace
  custom_config = {
    "enableIpAccessLists" = true
  }
}

resource databricks_ip_access_list my_office_allowed_list {
  provider     = databricks.workspace
  label        = "my_office_vpn"
  list_type    = "ALLOW"
  ip_addresses = ["999.999.999.999/24"] # CIDR notation
  depends_on   = [ databricks_workspace_conf.this ]
}