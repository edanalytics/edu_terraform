Unfortunately the Terraform/Snowflake connector [doesn't currently support](https://github.com/Snowflake-Labs/terraform-provider-snowflake/issues/250) "GRANT [privilege] ON ALL [tables|views|stages]". Actually this makes some sense, because Terraform couldn't manage/enforce this on tables created outside Terraform (which it doesn't know about).

To solve this, we use a module based on [this](https://github.com/badge/snowflaketf_grant_all) which implements this functionality by iterating over all tables/views/stages currently managed Terraform and creating a grant for each. Kinda ugly, but it works.

Likewise it expands "ALL" privileges to an actual list of specific privileges relevant for the object in question.