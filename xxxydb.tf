# - - - - - - - - - #
# Yandex Database (dedicated)
# - - - - - - - - - #

resource "yandex_ydb_database_dedicated" "xxx1" {
  name      = "xxxmain-ydb-dedicated"
  folder_id = "${var.yacloud-folder-id}"

  assign_public_ips  = true
  network_id = yandex_vpc_network.xxx-network.id
  subnet_ids = [
    yandex_vpc_subnet.xxxvpc-a.id,
    yandex_vpc_subnet.xxxvpc-b.id,
    yandex_vpc_subnet.xxxvpc-c.id
  ]

  resource_preset_id  = "medium"
  deletion_protection = true

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  storage_config {
    group_count     = 3
    storage_type_id = "ssd"
  }

  location {
    region {
      id = "ru-central1"
    }
  }
}


#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts
#
resource "yandex_iam_service_account" "sa-xxx1" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxx1"
}


#
# - - - - - - - - - #
# Static Keys
# - - - - - - - - - #
# Create Static Access Keys
#
resource "yandex_iam_service_account_static_access_key" "static-key-xxx1" {
  service_account_id = yandex_iam_service_account.sa-xxx1.id
  description        = "static access key for xxx1"
}

#
# - - - - - - - - - #
# IAM Member
# - - - - - - - - - #
# Create IAM member with rights
#

resource "yandex_resourcemanager_folder_iam_member" "sa-xxx1-iam-member" {

  for_each  = toset([
    "ydb.viewer",
    "ydb.editor"
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xxx1.id}"
}


resource "yandex_ydb_database_iam_binding" "viewer" {
  database_id = yandex_ydb_database_dedicated.xxx1.id
  role        = "ydb.viewer"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-xxx1.id}",
  ]
}

resource "yandex_ydb_database_iam_binding" "editor" {
  database_id = yandex_ydb_database_dedicated.xxx1.id
  role        = "ydb.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-xxx1.id}",
  ]
}

resource "yandex_iam_service_account_key" "sa-xxx1-auth-key" {
  service_account_id = "${yandex_iam_service_account.sa-xxx1.id}"
  description        = "key for sa-xxx1"
  key_algorithm      = "RSA_4096"
}

#
# - - - - - - - - - #
# Outputs
# - - - - - - - - - #

output "xxxmain-ydb-id" {
  description = "id of xxxmain-ydb"
  value       = yandex_ydb_database_dedicated.xxx1.id
  sensitive   = false
}

output "xxxmain-ydb-full-endpoint" {
  description = "full-endpoint of xxxmain-ydb"
  value       = yandex_ydb_database_dedicated.xxx1.ydb_full_endpoint
  sensitive   = false
}

output "xxxmain-ydb-api-endpoint" {
  description = "api-endpoint of xxxmain-ydb"
  value       = yandex_ydb_database_dedicated.xxx1.ydb_api_endpoint
  sensitive   = false
}

output "xxxmain-ydb-database-path" {
  description = "database-path of xxxmain-ydb"
  value       = yandex_ydb_database_dedicated.xxx1.database_path
  sensitive   = false
}

output "xxxmain-ydb-tls-enabled" {
  description = "tls-enabled of xxxmain-ydb"
  value       = yandex_ydb_database_dedicated.xxx1.tls_enabled
  sensitive   = false
}

output "xxxmain-ydb-created-at" {
  description = "created-at of xxxmain-ydb"
  value       = yandex_ydb_database_dedicated.xxx1.created_at
  sensitive   = false
}

output "xxxmain-ydb-status" {
  description = "status of xxxmain-ydb"
  value       = yandex_ydb_database_dedicated.xxx1.status
  sensitive   = false
}

output "access-key-sa-xxx1" {
  description = "access_key for sa-xxx1"
  value       = yandex_iam_service_account_static_access_key.static-key-xxx1.access_key
  sensitive   = true
}