# - - - - - - - - - - - - - - - - - - - - - - - - - #
# Yandex Serverless Database for xxx
# - - - - - - - - - - - - - - - - - - - - - - - - - #

resource "yandex_ydb_database_serverless" "xxx-ydbsl" {
  name      = "xxx-ydbsl"
  folder_id = "${var.yacloud-folder-id}"

  deletion_protection = false
}

#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts

resource "yandex_iam_service_account" "sa-xxx-ydbsl" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxx-ydbsl"
}

#
# - - - - - - - - - #
# Static Keys
# - - - - - - - - - #
# Create Static Access Keys

resource "yandex_iam_service_account_static_access_key" "static-key-xxx-ydbsl" {
  service_account_id = yandex_iam_service_account.sa-xxx-ydbsl.id
  description        = "static access key for xxx-ydbsl"
}

#
# - - - - - - - - - #
# IAM Member
# - - - - - - - - - #
# Create IAM member with rights
#

resource "yandex_resourcemanager_folder_iam_member" "sa-xxx-ydbsl-iam-member" {
  for_each  = toset([
    "ydb.viewer",
    "ydb.editor"
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xxx-ydbsl.id}"
}


resource "yandex_ydb_database_iam_binding" "xxx-ydbsl-viewer" {
  database_id = yandex_ydb_database_serverless.xxx-ydbsl.id
  role        = "ydb.viewer"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-xxx-ydbsl.id}",
  ]
}

resource "yandex_ydb_database_iam_binding" "xxx-ydbsl-editor" {
  database_id = yandex_ydb_database_serverless.xxx-ydbsl.id
  role        = "ydb.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-xxx-ydbsl.id}",
  ]
}

resource "yandex_iam_service_account_key" "sa-xxx-ydbsl-auth-key" {
  service_account_id = "${yandex_iam_service_account.sa-xxx-ydbsl.id}"
  description        = "key for sa-xxx-ydbsl"
  key_algorithm      = "RSA_4096"
}

#
# - - - - - - - - - #
# Outputs
# - - - - - - - - - #

output "xxx-ydbsl-id" {
  description = "id of xxx-ydbsl"
  value       = yandex_ydb_database_serverless.xxx-ydbsl.id
  sensitive   = false
}

output "xxx-ydbsl-full-endpoint" {
  description = "full-endpoint of xxx-ydbsl"
  value       = yandex_ydb_database_serverless.xxx-ydbsl.ydb_full_endpoint
  sensitive   = false
}

output "xxx-ydbsl-api-endpoint" {
  description = "api-endpoint of xxx-ydbsl"
  value       = yandex_ydb_database_serverless.xxx-ydbsl.ydb_api_endpoint
  sensitive   = false
}

output "xxx-ydbsl-database-path" {
  description = "database-path of xxx-ydbsl"
  value       = yandex_ydb_database_serverless.xxx-ydbsl.database_path
  sensitive   = false
}

output "xxx-ydbsl_tls-enabled" {
  description = "tls-enabled of xxx-ydbsl"
  value       = yandex_ydb_database_serverless.xxx-ydbsl.tls_enabled
  sensitive   = false
}

output "xxx-ydbsl-created-at" {
  description = "created-at of xxx-ydbsl"
  value       = yandex_ydb_database_serverless.xxx-ydbsl.created_at
  sensitive   = false
}

output "xxx-ydbsl-status" {
  description = "status of xxx-ydbsl"
  value       = yandex_ydb_database_serverless.xxx-ydbsl.status
  sensitive   = false
}

output "access-key-sa-xxx-ydbsl" {
  description = "access_key for sa-xxx-ydbsl"
  value       = yandex_iam_service_account_static_access_key.static-key-xxx-ydbsl.access_key
  sensitive   = true
}