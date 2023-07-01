#
# - - - - - - - - - #
# S3 frontlogs and backlogs
# - - - - - - - - - #
#


#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts
#
resource "yandex_iam_service_account" "sa-xxx-s3" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxx-s3"
}

resource "yandex_iam_service_account" "sa-xxx-s3" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxx-s3"
}

#
# ------------------------------------
#




#
# - - - - - - - - - #
# KMS Keys
# - - - - - - - - - #
# Create Static Access Keys
#
resource "yandex_kms_symmetric_key" "xxx-kmskey1" {
  name              = "xxx-kmskey1"
  description       = "KMS key for encrypting files in xxx bucket"
  default_algorithm = "AES_256"
  # rotation_period   = "8760h" // equal to 1 year
  lifecycle {
    prevent_destroy = true
  }
}

# Создание KMS ключа для server-side encryption
resource "yandex_kms_symmetric_key" "xxx-kmskey1" {
  name              = "xxx-kmskey1"
  description       = "KMS key for encrypting files in xxx bucket"
  default_algorithm = "AES_256"
  # rotation_period   = "8760h" // equal to 1 year
  lifecycle {
    prevent_destroy = true
  }
}
# 
# ------------------------------------
#


#
# - - - - - - - - - #
# Buckets
# - - - - - - - - - #
#
# Creating bucket frontlogs
#
resource "yandex_storage_bucket" "xxx-bucket" {
  access_key  = yandex_iam_service_account_static_access_key.static-key-front.access_key
  secret_key  = yandex_iam_service_account_static_access_key.static-key-front.secret_key
  folder_id   = "${var.yacloud-folder-id}"
  bucket      = "xxx-bucket"
  # 40gb
  max_size    = 42949672960
  # 120gb
  # max_size    = 128849018880
  # 360gb       
  # max_size    = 386547056640

  default_storage_class = "COLD"
  force_destroy         = false

  # for terr1-sa
  grant {
    id          = "${var.yacloud-service-account-id}"
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  # for s3-xxx-sa 
  grant {
    id          = "${yandex_iam_service_account.sa-xxx-s3.id}"
    type        = "CanonicalUser"
    permissions = ["READ", "WRITE"]
  }

  versioning {
    enabled = false
  }


  # Включение шифрования
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.xxx-kmskey1.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


# Creating bucket xxx
resource "yandex_storage_bucket" "xxx-bucket" {
  access_key  = yandex_iam_service_account_static_access_key.static-key-back.access_key
  secret_key  = yandex_iam_service_account_static_access_key.static-key-back.secret_key
  folder_id   = "${var.yacloud-folder-id}"
  bucket      = "xxx-bucket"
  # 40gb
  max_size    = 42949672960
  # 120gb
  # max_size    = 128849018880
  # 360gb       
  # max_size    = 386547056640

  default_storage_class = "COLD"
  force_destroy         = false

  # for terr1-sa
  grant {
    id          = "${var.yacloud-service-account-id}"
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  # for s3-adm-xxx-sa
  grant {
    id          = "${yandex_iam_service_account.sa-xxx-s3.id}"
    type        = "CanonicalUser"
    permissions = ["READ", "WRITE"]
  }

  versioning {
    enabled = false
  }

  # Включение шифрования
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.backlogs-kmskey1.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

#
# ------------------------------------
#


#
# - - - - - - - - - #
# Static Keys
# - - - - - - - - - #
# Create Static Access Keys for key-xxx
#
resource "yandex_iam_service_account_static_access_key" "static-key-xxx" {
  service_account_id = yandex_iam_service_account.sa-frontlogs-s3.id
  description        = "static access key for frontlogs"
}

# Create Static Access Keys for key-back
resource "yandex_iam_service_account_static_access_key" "static-key-back" {
  service_account_id = yandex_iam_service_account.sa-backlogs-s3.id
  description        = "static access key for backlogs"
}
#
# ------------------------------------
#


#
# - - - - - - - - - #
# IAM Bindings
# - - - - - - - - - #
#
# IAM 
#
# Назначение прав на KMS ключи для работы с шифрованным бакетом для s3-xxx-sa
# --- 1 --- #
resource "yandex_resourcemanager_folder_iam_member" "binding-for-terr-enc-dec" {
  folder_id = "${var.yacloud-folder-id}"
  role   = "kms.keys.encrypterDecrypter"
  member = "serviceAccount:${var.yacloud-service-account-id}"
}

resource "yandex_resourcemanager_folder_iam_member" "binding-for-terr-se" {
  folder_id = "${var.yacloud-folder-id}"
  role   = "storage.admin"
  member = "serviceAccount:${var.yacloud-service-account-id}"
}

# Назначение прав на KMS ключи для работы с шифрованным бакетом для s3-xxx-sa
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-terr-storage-admin" {
  folder_id = "${var.yacloud-folder-id}"
  role      = "storage.admin"
  members   = ["serviceAccount:${var.yacloud-service-account-id}"] 
}


# --- 2 --- #

resource "yandex_resourcemanager_folder_iam_member" "binding-for-xxx-enc-dec" {
  folder_id = "${var.yacloud-folder-id}"
  role   = "kms.keys.encrypterDecrypter"
  member = "serviceAccount:${yandex_iam_service_account.sa-xxx-s3.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "binding-for-xxx-se" {
  folder_id = "${var.yacloud-folder-id}"
  role   = "storage.admin"
  member = "serviceAccount:${yandex_iam_service_account.sa-xxx-s3.id}"
}

# Назначение прав на KMS ключи для работы с шифрованным бакетом для s3-xxx-sa
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-xxx-storage-admin" {
  folder_id = "${var.yacloud-folder-id}"
  role      = "storage.admin"
  members   = ["serviceAccount:${yandex_iam_service_account.sa-xxx-s3.id}"] 
}

# --- 3 --- #

resource "yandex_resourcemanager_folder_iam_member" "binding-for-xxx-enc-dec" {
  folder_id = "${var.yacloud-folder-id}"
  role   = "kms.keys.encrypterDecrypter"
  member = "serviceAccount:${yandex_iam_service_account.sa-xxx-s3.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "binding-for-xxx-se" {
  folder_id = "${var.yacloud-folder-id}"
  role   = "storage.admin"
  member = "serviceAccount:${yandex_iam_service_account.sa-xxx-s3.id}"
}

# Назначение прав на KMS ключи для работы с шифрованным бакетом для s3-xxx-sa
resource "yandex_resourcemanager_folder_iam_binding" "binding-for-xxx-storage-admin" {
  folder_id = "${var.yacloud-folder-id}"
  role      = "storage.admin"
  members   = ["serviceAccount:${yandex_iam_service_account.sa-xxx-s3.id}"] 
}
#
# ------------------------------------
#


#
# - - - - - - - - - #
# Output values
# - - - - - - - - - #


# Output values for xxx
output "access-key-s3-sa-xxx-s3" {
  description = "access_key for sa-xxx-s3"
  value       = yandex_iam_service_account_static_access_key.static-key-front.access_key
  sensitive   = true
}

output "access-key-s3-sa-xxx-s3" {
  description = "secret_key for sa-xxx-s3"
  value       = yandex_iam_service_account_static_access_key.static-key-back.secret_key
  sensitive   = true
}
#
# ------------------------------------
#

