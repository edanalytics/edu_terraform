module edu_databricks {
  source = "../../modules/edu-databricks"
  environments = var.environments
  workspace_id = var.workspace_id
  storage_location = var.storage_location
}
