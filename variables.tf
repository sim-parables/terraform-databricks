## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "databricks_admin_group" {
  type        = string
  description = "Databricks Admin Group Name for Cluster Policy"
}

variable "databricks_cluster_name" {
  type        = string
  description = "Databricks Cluster Name"
}

variable "databricks_catalog_name" {
  type        = string
  description = "Databricks Unity Catalog Name"
}

variable "databricks_catalog_external_location_url" {
  type        = string
  description = "Databricks Unity Catalog Cloud External Location URL"
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "DATABRICKS_CLUSTERS" {
  type        = number
  description = "Number representing the amount of Databricks Clusters to spin up"
  default     = 0
}

variable "databricks_schema_name" {
  type        = string
  description = "Databricks Example Schema Name"
  default     = "example_metastore"
}

variable "databricks_volume_name" {
  type        = string
  description = "Databricks Example Volume Name"
  default     = "example_volume"
}

variable "databricks_secret_scope" {
  type        = string
  description = "Databricks Secret Scope Name"
  default     = "example_secret_scope"
}

variable "databricks_secrets" {
  description = "Map of Databricks Secrets"
  default     = []
  sensitive   = true
  type        = list(object({
    secret_name = string
    secret_value = string
  }))
}

variable "databricks_cluster_policy_name" {
  type        = string
  description = "Databricks Cluster Policy Name"
  default     = "example-cluster-policy"
}

variable "databricks_cluster_policy_autotermination_minutes" {
  type        = number
  description = "Databricks Cluster Policy Instance Auto-Termination in Minutes (Minimum: 10 minutes)"
  default     = 10
}

variable "databricks_cluster_data_security_mode" {
  type        = string
  description = "Databricks Unity Catalog Feature to secure access/isolation. (Default: USER_ISOLATION)"
  default     = "USER_ISOLATION"
}

variable "databricks_instance_pool_node_name" {
  type        = string
  description = "Databricks Worker Nodes Instance Pool's Name"
  default     = "example-node-instace-pool"
}

variable "databricks_instance_pool_node_max_capacity" {
  type        = number
  description = "Databricks Worker Nodes Instance Pool's Maximum Number of Allocated Nodes"
  default     = 2
}

variable "databricks_instance_pool_driver_name" {
  type        = string
  description = "Databricks Driver Nodes Instance Pool's Name"
  default     = "example-driver-instace-pool"
}

variable "databricks_instance_pool_driver_max_capacity" {
  type        = number
  description = "Databricks Driver Instance Pool's Maximum Number of Allocated Nodes"
  default     = 2
}

variable "databricks_cluster_spark_env_variable" {
  type        = map(string)
  description = "Databricks CLuster Spark Environment Variables"
  default     = {}
}

variable "databricks_cluster_spark_conf_variable" {
  type        = map(string)
  description = "Databricks Cluster Spark Conf Parameters"
  default     = {}
}

variable "databricks_cluster_library_files" {
  description = "Databricks Unity Catalog Cluster Library Files to be added to Volume for Install"
  default     = []
  type        = list(object({
    file_name      = string
    content_base64 = string
  }))
}

variable "databricks_cluster_azure_attributes" {
  description = "Azure Compute Configurations for Databricks Clusters"
  default     = null
  type        = object({
    attributes = object({
      availability       = string
      first_on_demand    = number
      spot_bid_max_price = number 
    })
  })
}

variable "tags" {
  type        = map(string)
  description = "Azure Resource Tag(s)"
  default     = {}
}

variable "client_secret_expiration" {
  type        = string
  description = "Service Account Secret Relative Expiration from Creation"
  default     = "1h"
}