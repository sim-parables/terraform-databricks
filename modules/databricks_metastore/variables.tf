## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "databricks_unity_admin_group" {
  type        = string
  description = "Databricks Accounts Admin Group Name"
}

variable "databricks_workspace_id" {
  type        = string
  description = "Databricks workspace ID to be enabled with Unity Catalog."
}

variable "databricks_storage_root" {
  type        = string
  description = "Databricks Accounts Storage Root ID"
}

variable "cloud_region" {
  type        = string
  description = "Cloud Provider Region"
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "databricks_metastore_name" {
  type        = string
  description = "Display Name for Databricks Accounts Metastore"
  default     = "Primary"
}

variable "databricks_catalog_name" {
  type        = string
  description = "Display Name for Databricks Accounts Metastore Catalog"
  default     = "hive_metastore"
}

variable "databricks_metastore_grants" {
  description = <<EOT
    List of Databricks Metastore Specific Grants. Default privileges when creating a metastore
    should include: CREATE_CATALOG, CREATE_CONNECTION, CREATE_EXTERNAL_LOCATION, CREATE_STORAGE_CREDENTIAL
  EOT
  default     = []
  type        = list(object({
    principal = string
    privileges = list(string)
  }))
}