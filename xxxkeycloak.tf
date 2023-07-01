# - - - - - - - - - #
# xxxx host
# - - - - - - - - - #


#
# - - - - - - - - - #
# Log group for xxxkeycloak
# - - - - - - - - - #
# Create log group
#

resource "yandex_logging_group" "xxxkeycloak-log-group" {
  name              = "xxxkeycloak-log-group"
  retention_period  = "72h0m0s"
  folder_id         = "${var.yacloud-folder-id}"
}


#
# - - - - - - - - - #
# IAM Member
# - - - - - - - - - #
# Create IAM member with rights for xxxkeycloak-a
#

resource "yandex_resourcemanager_folder_iam_member" "sa-xxxkeycloak-iam-member" {
  for_each  = toset([
    "compute.images.user",
    "editor",
    "vpc.user",
    "kms.keys.encrypterDecrypter",
    "logging.writer",
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xxxkeycloak.id}"
}

#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts
#
resource "yandex_iam_service_account" "sa-xxxkeycloak" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxxkeycloak"
}


resource "yandex_compute_instance" "xxxkeycloak" {

  name        = "xxxkeycloak"
  zone        = "ru-central1-a"
  hostname    = "xxxkeycloak"
  description = "xxxkeycloak-a"

  labels    = {
    billingtype = "xxxkeycloak"
  }

  service_account_id = yandex_iam_service_account.sa-xxxkeycloak.id

  resources {
    cores = 2
    memory = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_lts_22}"
      description = "Disk for the xxxkeycloak"
      size        = 40
      type        = "network-hdd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.xxxvpc-a.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.sg-xxxkeycloak.id ]
    
    nat_ip_address      = "x"
    ip_address          = "x"
  }

  allow_stopping_for_update = true

  metadata = {
    user-data = file("${path.module}/yaml/xxxkeycloak.yaml")
  }
}
