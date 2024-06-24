terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      configuration_aliases = [ databricks.workspace ]
    }
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS GROUP RESOURCE DEFINITION
##
## This resource block defines a group within Databricks.
## 
## Parameters:
## - `display_name`: Display name of the group. Example: "engineer_group"
## - `allow_cluster_create`: Whether the group is allowed to create clusters. Example: true
## - `allow_instance_pool_create`: Whether the group is allowed to create instance pools. Example: false
## - `databricks_sql_access`: Whether the group is allowed Databricks SQL access. Example: true
## ---------------------------------------------------------------------------------------------------------------------
resource "databricks_group" "this" {
  provider                   = databricks.workspace
  
  display_name               = var.group_name
  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
  databricks_sql_access      = var.allow_databricks_sql_access
}

## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS GROUP MEMBER RESOURCE
##
## Adds a member to a Databricks group. The member can be either a user or a service principal.
##
## Parameters:
## - `group_id`: The ID of the Databricks group.
## - `member_id`: The ID of the member to add to the group.
## ---------------------------------------------------------------------------------------------------------------------
resource "databricks_group_member" "this" {
  provider  = databricks.workspace
  count     = length(var.member_ids)
  
  group_id  = databricks_group.this.id
  member_id = var.member_ids[count.index]
}