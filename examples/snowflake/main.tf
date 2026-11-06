# SPDX-FileCopyrightText: 2022 Education Analytics
# SPDX-License-Identifier: MPL-2.0

module edu_snowflake {
  source = "git::github.com/edanalyics/edu_terraform.git//modules/edu-snowflake?ref=main"
  # ^ pinning to `main` isn't ideal; once we have stable releases, this should be changed, e.g. `v1.0.0`
  
  snowflake_profile = var.snowflake_profile

  # (optional) default environments are prod and dev; uncomment this if you also want test.
  #environments = [
  #  {
  #    name = "prod"
  #    prefix = ""
  #    suffix = ""
  #  },
  #  {
  #    name = "dev"
  #    prefix = "dev_"
  #    suffix = "_dev"
  #  },
  #  {
  #    name = "test"
  #    prefix = "test_"
  #    suffix = "_test"
  #  }
  #]
  #############################################################################
  ### Q: is this ^ a good way to handle the "test" env? and specifically what
  ###    about the below 2 grants (from bottom of base_setup/10_test_raw.sql)?
  #############################################################################
  # grant role db_test_raw_r to role transformer_dev;
  # grant role db_test_raw_r to role ea_read;

  # To create `tenant_viewer__{tenant_code}` roles and grants, fill out the codes below.
  # (Soon, this will likely be automated via a DAG that pulls tenant_codes from User Management.)
  # tenant_codes = ["tenant1", "tenant2", "tenant3"]
}
