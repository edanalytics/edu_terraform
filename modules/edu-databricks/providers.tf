terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = "1.85.0"
      configuration_aliases = [ databricks.account, databricks.workspace ]
    }
  }
}
provider databricks {
  alias  = "account"
  profile = "ACCOUNT"
}
provider databricks {
  alias  = "workspace"
  profile = "DEFAULT"
}