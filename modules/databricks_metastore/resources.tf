terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      configuration_aliases = [ databricks.accounts ]
    }
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS METASTORE RESOURCE
##
## This resource block defines a Databricks metastore configuration.
##
## Parameters:
## - `name`: The name of the Databricks metastore.
## - `owner`: The owner group for the Databricks Unity Catalog admin group.
## - `region`: The cloud region where the metastore is created.
## - `storage_root`: The root storage path for the metastore.
## - `force_destroy`: Indicates if the metastore should be forcefully destroyed.
## ---------------------------------------------------------------------------------------------------------------------
resource "databricks_metastore" "this" {
  provider      = databricks.accounts
  name          = var.databricks_metastore_name
  owner         = var.databricks_unity_admin_group
  region        = var.cloud_region
  storage_root  = var.databricks_storage_root
  force_destroy = true
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS METASTORE ASSIGNMENT RESOURCE
##
## This resource block assigns a Databricks metastore to multiple workspaces.
##
## Parameters:
## - `workspace_id`: The ID of the Databricks workspace to assign the metastore to.
## - `metastore_id`: The ID of the Databricks metastore to assign.
## - `default_catalog_name`: The default catalog name to be used in the metastore.
## ---------------------------------------------------------------------------------------------------------------------
resource "databricks_metastore_assignment" "this" {
  provider             = databricks.accounts

  workspace_id         = var.databricks_workspace_id
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = var.databricks_catalog_name
}