module edu_databricks {
  source = "git::github.com/edanalyics/edu_terraform.git/modules/edu-databricks?ref=feature/databricks_for_edu"
  
  databricks_profile = var.databricks_profile

  workspace_id = var.workspace_id
  storage_location = var.storage_location

}
