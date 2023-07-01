# - - - - - - - - - - - - - - - #
# xxxYandexFunctions
# - - - - - - - - - - - - - - - #


#
# - - - - - - - - - - - - - - - #
# Log group for ydbfunctions
# - - - - - - - - - - - - - - - #
# Create log group
#

resource "yandex_logging_group" "ydb-python-insert-log-group" {
  name              = "ydbfunctions-log-group"
  retention_period  = "72h0m0s"
  folder_id         = "${var.yacloud-folder-id}"
}



#
# - - - - - - - - - #
# Static Access Keys
# - - - - - - - - - #
# Create Static Access Keys
#

resource "yandex_iam_service_account_static_access_key" "static-key-ydb-python-ya-functions" {
  service_account_id = yandex_iam_service_account.sa-ydbfunc1.id
  description        = "static access key for sa-ydbfunc1 account"
}




#
# - - - - - - - - - - - - - - - #
# IAM Member
# - - - - - - - - - - - - - - - #
# Create IAM member with rights for xxx-REST-a
#

resource "yandex_resourcemanager_folder_iam_member" "sa-ydbfunc1-iam-member" {

  for_each  = toset([
    "compute.images.user",
    "editor",
    "vpc.user",
    "kms.keys.encrypterDecrypter",
    "logging.writer",
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-ydbfunc1.id}"
}


resource "yandex_iam_service_account_key" "sa-ydbfunc1-auth-key" {
  service_account_id = "${yandex_iam_service_account.sa-ydbfunc1.id}"
  description        = "key for sa-ydbfunc1"
  key_algorithm      = "RSA_4096"
  # pgp_key            = "keybase:keybaseusername"
}

#
# - - - - - - - - - - - - - - - #
# Service Accounts
# - - - - - - - - - - - - - - - #
# Create SA accounts
#
resource "yandex_iam_service_account" "sa-ydbfunc1" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-ydbfunc1"
}


resource "yandex_function" "ydb-python-insert" {
  name               = "ydb-python-insert"
  description        = "YDB Python"
  user_hash          = "xxxxx"
  runtime            = "python39"
  entrypoint         = "index.handler"
  memory             = "128"
  execution_timeout  = "10"
  # loggroup_id        = yandex_logging_group.ydb-python-insert-log-group.id
  service_account_id = yandex_iam_service_account.sa-ydbfunc1.id
  tags               = ["ydb_python_insert"]
  # secrets {
  #   id = "${yandex_lockbox_secret.secret.id}"
  #   version_id = "${yandex_lockbox_secret_version.secret_version.id}"
  #   key = "secret-key"
  #   environment_variable = "ENV_VARIABLE"
  # }
  content {
    zip_filename = "ydb_python_insert.zip"
  }
  environment = {
    # "AWS_ACCESS_KEY_ID" = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
    # "AWS_SECRET_ACCESS_KEY" = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
    "YDB_ENDPOINT" = "grpcs://lb.xxxx.ydb.mdb.yandexcloud.net:2135"
    "YDB_DATABASE" = "/ru-central1/xxx/xxx"
    "USE_METADATA_CREDENTIALS" = "1"
  }
}


output "access-key-sa-ydbfunc1" {
  description = "access_key for sa-ydbfunc1"
  value       = yandex_iam_service_account_static_access_key.static-key-ydb-python-ya-functions.access_key
  sensitive   = true
}