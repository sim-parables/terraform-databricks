output "databricks_access_token" {
  description = "Databricks Workspace Service Principal Access Token"
  value       = module.databricks_workspace_access_token.databricks_token
  sensitive   = true
}

output "databricks_secret_scope_name" {
  description = "Databricks Workspace Secret Scope Name"
  value       = module.databricks_secret_scope.databricks_secret_scope
}

output "databricks_secret_names" {
  description = "List of Databricks Workspace Secret Names"
  value       = [ 
    for k,v in module.databricks_service_account_key_name_secret[*].databricks_secret_name :
    v.databricks_secret_name
  ]
}

output "databricks_secret_client_secret_name" {
  description = "Databricks Workspace Secret Key for Client Secret"
  value       = module.databricks_service_account_key_data_secret.databricks_secret_name
}

output "databricks_cluster_ids" {
  description = "List of Databricks Workspace Cluster IDs"
  value       = module.databricks_cluster[*].databricks_cluster_id
}

output "databricks_external_location_url" {
  description = "Azure Metastore Bucket ABFS URL"
  value       = module.databricks_metastore.databricks_external_location_url
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

output "azure_keyvault_name" {
  description = "Azure Key Vault Name"
  value       = module.key_vault.key_vault_name
}

output "azure_keyvault_secret_client_id_name" {
  description = "Azure Key Vault Secret Key for Client ID"
  value       = module.key_vault_client_id.key_vault_secret_name
}

output "azure_keyvault_secret_client_secret_name" {
  description = "Azure Key Vault Secret Key for Client Secret"
  value       = module.key_vault_client_secret.key_vault_secret_name
}