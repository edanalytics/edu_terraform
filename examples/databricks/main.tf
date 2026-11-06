# SPDX-FileCopyrightText: 2022 Education Analytics
# SPDX-License-Identifier: MPL-2.0

module edu_databricks {
  source = "../../modules/edu-databricks"
  environments = var.environments
  workspace_id = var.workspace_id
  storage_location = var.storage_location
}
