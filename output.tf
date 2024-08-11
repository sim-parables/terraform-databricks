output "databricks_access_token" {
  description = "Databricks Workspace Service Principal Access Token"
  value       = module.databricks_workspace_access_token.databricks_token
  sensitive   = true
}

output "databricks_secret_scope_name" {
  description = "Databricks Workspace Secret Scope Name"
  value       = module.databricks_secret_scope.databricks_secret_scope
}

output "databricks_cluster_ids" {
  description = "List of Databricks Workspace Cluster IDs"
  value       = module.databricks_cluster[*].databricks_cluster_id
}

output "databricks_example_holdings_data_path" {
  description = "Databricks Example Holding Data Unity Catalog File Path"
  value       = module.databricks_sample_data.databricks_volume_file_paths[0]
}

output "databricks_example_weather_data_path" {
  description = "Databricks Example Weather Data Unity Catalog File Path"
  value       = module.databricks_sample_data.databricks_volume_file_paths[1]
}

output "databricks_unity_catalog_table_paths" {
  description = "Databricks Unity Catalog Table Paths"
  value       = module.databricks_sample_tables[*].databricks_schema_table_paths[0]
}