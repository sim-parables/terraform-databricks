terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      configuration_aliases = [ 
        databricks.accounts,
        databricks.workspace 
      ]
    }
  }
}

locals {
  databricks_schemas = [
    {
      catalog_name = var.databricks_catalog_name
      schema_name  = var.databricks_schema_name
      comment      = "Example Schema Created with Terraform"
      properties   = {
        kind = "various"
      }
    }
  ]
  
  databricks_volumes = [
    {
      catalog_name     = var.databricks_catalog_name
      schema_name      = var.databricks_schema_name
      volume_name      = var.databricks_volume_name
      volume_type      = "EXTERNAL"
      storage_location = var.databricks_catalog_external_location_url
      comment          = "Example Volume Created with Terraform"
    },
    {
      catalog_name     = var.databricks_catalog_name
      schema_name      = var.databricks_schema_name
      volume_name      = "Libraries"
      volume_type      = "EXTERNAL"
      storage_location = var.databricks_catalog_external_location_url
      comment          = "Cluster Library Volume Created with Terraform"
    },
  ]
  
  databricks_files = concat([
    {
      catalog_name   = var.databricks_catalog_name
      schema_name    = var.databricks_schema_name
      volume_name    = var.databricks_volume_name
      file_name      = "example_holdings.csv"
      content_base64 = data.http.sample_holdings_data.response_body_base64
    },
    {
      catalog_name   = var.databricks_catalog_name
      schema_name    = var.databricks_schema_name
      volume_name    = var.databricks_volume_name
      file_name      = "example_weather.csv"
      content_base64 = data.http.sample_weather_data.response_body_base64
    },
  ],
  [
    for l in var.var.databricks_cluster_library_files :
    {
      catalog_name   = var.databricks_catalog_name
      schema_name    = var.databricks_schema_name
      volume_name    = "Libraries"
      file_name      = l.file_name
      content_base64 = l.content_base64
    }
  ])
  
  databricks_cluster_library_paths = [
    {
      artifact = "/Volumes/${var.databricks_catalog_name}/${var.databricks_schema_name}/Libraries"
      artifact_type = "LIBRARY_JAR"
      match_type    = "PREFIX_MATCH"
    },
  ]

  databricks_cluster_jar_libraries = [
    for l in var.databricks_cluster_library_files :
    "/Volumes/${var.databricks_catalog_name}/${var.databricks_schema_name}/Libraries/${l.file_name}" if strcontains(l.file_name, ".jar")
  ]

  databricks_cluster_whl_libraries = [
    for l in var.databricks_cluster_library_files :
    "/Volumes/${var.databricks_catalog_name}/${var.databricks_schema_name}/Libraries/${l.file_name}" if strcontains(l.file_name, ".whl")
  ]
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS SECRET SCOPE MODULE
## 
## This module creates a Databricks secret scope in an Azure Databricks workspace. We're unable to create a
## Databricks Secret Scope backed by Azure Key Vault due to the workspace provider requiring Azure specific
## authentication methods (Cannot be created using PAT).
## 
## Parameters:
## - `secret_scope`: Specifies the name of Databricks Secret Scope.
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_secret_scope" {
  source = "./modules/databricks_secret_scope"

  secret_scope = var.databricks_secret_scope

  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS WORKSPACE ACCESS TOKEN MODULE
## 
## This module creates a Databricks Person Access Token (PAT) an Azure Databricks workspace. This token can be used to
## authenticate with the Databricks Workspace via CLI/Curl without needing to pass Service Principal Credentials.
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_workspace_access_token" {
  source   = "./modules/databricks_pat_token"

  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS SERVICE ACCOUNT SECRETS MODULE
## 
## This module creates a service account secrets in a Databricks secret scope. The secret stores the 
## client ID/ secret of cloud provider.
## 
## Parameters:
## - `secret_scope_id`: Specifies the secret scope ID where the secret will be stored
## - `secret_name`: Specifies the name of the secret
## - `secret_data`: Specifies the data of the secret
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_service_account_secrets" {
  source      = "./modules/databricks_secret"
  depends_on  = [ module.databricks_metastore ]
  for_each    = var.databricks_secrets
  
  secret_scope_id = module.databricks_secret_scope.databricks_secret_scope_id
  secret_name     = each.value.secret_name
  secret_data     = each.value.secret_data
  
  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS DRIVER NODE INSTANCE POOL MODULE
## 
## This module creates an instance pool in a Databricks workspace specifically for driver nodes.
## 
## Parameters:
## - `instance_pool_name`: Specifies the name of the instance pool
## - `instance_pool_max_capacity`: Specifies the maximum capacity of the instance pool
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_instance_pool_driver" {
  source       = "./modules/databricks_instance_pool"
  
  instance_pool_name         = var.databricks_instance_pool_driver_name
  instance_pool_max_capacity = var.databricks_instance_pool_driver_max_capacity

  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS WORKER NODE INSTANCE POOL MODULE
## 
## This module creates an instance pool in a Databricks workspace specifically for worker nodes.
## 
## Parameters:
## - `instance_pool_name`: Specifies the name of the instance pool
## - `instance_pool_max_capacity`: Specifies the maximum capacity of the instance pool
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_instance_pool_node" {
  source       = "./modules/databricks_instance_pool"
  
  instance_pool_name         = var.databricks_instance_pool_node_name
  instance_pool_max_capacity = var.databricks_instance_pool_node_max_capacity

  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS CLUSTER POLICY MODULE
## 
## This module sets up a cluster policy in a Databricks workspace.
## 
## Parameters:
## - `cluster_policy_name`: Specifies the name of the cluster policy.
## - `group_name`: Specify the name of the engineer group to associate the policy with.
## - `data_security_mode`: Databrick cluster security mode
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_cluster_policy" {
  source = "./modules/databricks_cluster_policy"
  
  cluster_policy_name           = var.databricks_cluster_policy_name
  group_name                    = var.databricks_admin_group
  data_security_mode            = var.databricks_cluster_data_security_mode
  instance_pool_autotermination = var.databricks_cluster_policy_autotermination_minutes

  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS CLUSTER MODULE
## 
## This module sets up a Databricks cluster with the specified configurations.
## 
## Parameters:
## - `cluster_name`: Specify the name of the Databricks cluster.
## - `node_instance_pool_id`: Specify the instance pool IDs for worker nodes.
## - `driver_instance_pool_id`: Specify the instance pool IDs for driver nodes.
## - `cluster_policy_name`: Specify the name of the cluster policy.
## - `cluster_policy_id`: Specify the ID of the cluster policy.
## - `library_paths`: Library Volume to be included in the ALLOWED LIST on Databricks Cluster
## - `jar_libraries`: Volume paths to jar libraries to be installed on Databricks Cluster
## - `whl_libraries`: Volume paths to whl libraries to be installed on Databricks Cluster
## - `spark_env_variable`: Define Spark environment variables.
## - `spark_conf_variable`: Define Spark configuration variables.
## - `azure_attributes`: Azure compute configurations for Databricks Clusters
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_cluster" {
  source     = "./modules/databricks_cluster"
  depends_on = [ module.databricks_cluster_policy ]
  count      = var.DATABRICKS_CLUSTERS
  
  cluster_name            = "${var.databricks_cluster_name}-${count.index}"
  node_instance_pool_id   = module.databricks_instance_pool_node.instance_pool_id
  driver_instance_pool_id = module.databricks_instance_pool_driver.instance_pool_id
  cluster_policy_name     = module.databricks_cluster_policy.cluster_policy_name
  cluster_policy_id       = module.databricks_cluster_policy.cluster_policy_id
  library_paths           = local.databricks_cluster_library_paths
  jar_libraries           = local.databricks_cluster_jar_libraries
  whl_libraries           = local.databricks_cluster_whl_libraries
  spark_env_variable      = var.databricks_cluster_spark_env_variable
  spark_conf_variable     = var.databricks_cluster_spark_conf_variable
  azure_attributes        = var.databricks_cluster_azure_attributes

  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## HTTP DATA SOURCE
## 
## Download contents of sample holdings data to be placed in Databricks Unity Catalog Volume.
## 
## Parameters:
## - `url`: Sample data URL.
## - `request_headers`: Mapping of HTTP request headers.
## ---------------------------------------------------------------------------------------------------------------------
data "http" "sample_holdings_data" {
  url = "https://duckdb.org/data/holdings.csv"

  # Optional request headers
  request_headers = {
    Accept  = "text/csv"
    Content = "text/csv"
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## HTTP DATA SOURCE
## 
## Download contents of sample weather data to be placed in Databricks Unity Catalog Volume.
## 
## Parameters:
## - `url`: Sample data URL.
## - `request_headers`: Mapping of HTTP request headers.
## ---------------------------------------------------------------------------------------------------------------------
data "http" "sample_weather_data" {
  url = "https://duckdb.org/data/weather.csv"

  # Optional request headers
  request_headers = {
    Accept  = "text/csv"
    Content = "text/csv"
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS SAMPLE DATA MODULE
## 
## This module sets up sample data for experimentation in Databricks Unity Catalog
## by establishing UC Schemas/ UC Volumes and file uploads. It also configures the preferred
## library installation approach uploading cluster library files to install within a
## dedicated Volume in Unity Catalog.
## 
## Parameters:
## - `databricks_catalog_name`: Databricks Unity Catalog name.
## - `databricks_schemas`: Map of Databricks Unity Catalog Schema attributes to create.
## - `databricks_volumes`: Map of Databricks Unity Catalog Volume attributes to create.
## - `databricks_files`: Map of Databricks files to upload into Unity Catalog Volumes.
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_sample_data" {
  source       = "./modules/databricks_catalog_config"
  depends_on   = [ module.databricks_metastore ]
  
  databricks_schemas = local.databricks_schemas
  databricks_volumes = local.databricks_volumes
  databricks_files   = local.databricks_files

  providers = {
    databricks.workspace = databricks.workspace
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## DATABRICKS SAMPLE DATA MODULE
## 
## This module sets up sample data for experimentation in Databricks Unity Catalog
## by establishing UC Schemas/ UC Volumes and file uploads. It also configures the preferred
## library installation approach uploading cluster library files to install within a
## dedicated Volume in Unity Catalog.
## 
## Parameters:
## - `databricks_tables`: Databricks Unity Catalog Table attributes to create.
## ---------------------------------------------------------------------------------------------------------------------
module "databricks_sample_tables" {
  source     = "./modules/databricks_catalog_config"
  count      = var.DATABRICKS_CLUSTERS > 0 ? 1 : 0
  depends_on = [ 
    module.databricks_sample_data,
    module.databricks_cluster
  ]

  databricks_tables = [
    {
      cluster_id         = module.databricks_cluster[count.index].databricks_cluster_id
      catalog_name       = var.databricks_catalog_name
      schema_name        = var.databricks_schema_name
      table_name         = "example_weather"
      table_type         = "EXTERNAL"
      data_source_format = "DELTA"
      storage_location   = var.databricks_catalog_external_location_url
      comment            = "Table created with Terraform"
      table_columns      = [
        {
          name     = "city"
          type     = "string"
          comment  = "Name of US City"
          nullable = false
        },
        {
          name     = "total_precipitation"
          type     = "float"
          comment  = "Total accumulation of Rain Water"
          nullable = false
        }
      ]
    }
  ]

  providers = {
    databricks.workspace = databricks.workspace
  }
}