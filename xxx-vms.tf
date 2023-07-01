#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts
#

resource "yandex_iam_service_account" "sa-xxx-vm" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxx-vm"
}


#
# - - - - - - - - - #
# Static Access Keys
# - - - - - - - - - #
# Create Static Access Keys
#

resource "yandex_iam_service_account_static_access_key" "static-key-xxx-vm" {
  service_account_id = yandex_iam_service_account.sa-xxx-vm.id
  description        = "static access key for sa-xxx-vm account"
}


#
# - - - - - - - - - #
# IAM Member
# - - - - - - - - - #
# Create IAM member with rights for xxx
#

resource "yandex_resourcemanager_folder_iam_member" "sa-xxx-vm-iam-member" {
  # folder_id = "${var.yacloud-folder-id}"
  # role      = "editor"
  # member    = "serviceAccount:${yandex_iam_service_account.sa-xxx.id}"

  for_each  = toset([
    "compute.images.user",
    "editor",
    "vpc.securityGroups.user",
    "container-registry.images.puller",
    "vpc.user",
    "kms.keys.encrypterDecrypter",
    "logging.writer",
    "vpc.admin"
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xxx-vm.id}"
}



#
# - - - - - - - - - #
# xxx-A-VM1
# - - - - - - - - - #
# Create VM
#

resource "yandex_compute_instance" "xxx-a-vm1" {

  name        = "xxx-a-vm1"
  zone        = "ru-central1-a"
  hostname    = "xxx-a-vm1"
  description = "xxx-a"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "vmfront"
  }

  service_account_id = yandex_iam_service_account.sa-xxx-vm.id

  resources {
    cores = 4
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_lts_22}"
      description = "xxx-disk"
      size        = 50
      type        = "network-ssd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.xxx-a.id
    nat                 = true
    security_group_ids  = [ yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.sg-incoming-home.id,  yandex_vpc_security_group.sg-gitlab-1.id, yandex_vpc_security_group.sg-frontvms.id, yandex_vpc_security_group.sg-incoming-cloudflare.id ]
    ip_address      = "xxx"
    nat_ip_address  = "xxx"
  }
 
  allow_stopping_for_update = false

  metadata = {
    user-data = file("${path.module}/yaml/xxx.yaml")
  }
}



#
# - - - - - - - - - #
# xxx-B-VM1
# - - - - - - - - - #
# Create VM
#

resource "yandex_compute_instance" "xxx-b-vm1" {

  name        = "xxx-b-vm1"
  zone        = "ru-central1-b"
  hostname    = "xxxx-b-vm1"
  description = "xxx-b"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "xxx"
  }

  service_account_id = yandex_iam_service_account.sa-xxx-vm.id

  resources {
    cores = 4
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_lts_22}"
      description = "xxx-disk"
      size        = 50
      type        = "network-ssd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.xxx-b.id
    nat                 = true
    security_group_ids  = [ yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.sg-incoming-home.id,  yandex_vpc_security_group.sg-gitlab-1.id, yandex_vpc_security_group.sg-frontvms.id, yandex_vpc_security_group.sg-incoming-cloudflare.id ]
    ip_address      = "xxx"
    nat_ip_address  = "xxx"
  }

 
  allow_stopping_for_update = false

  metadata = {
    user-data = file("${path.module}/yaml/xxx.yaml")
  }
}


#
# - - - - - - - - - #
# Log group for xxx actions
# - - - - - - - - - #
# Create log group
#

resource "yandex_logging_group" "xxx-log-group" {
  name              = "xxx-log-group"
  retention_period  = "72h0m0s"
  folder_id         = "${var.yacloud-folder-id}"
}


#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
# - - - - - - - - - #
# Outputs
# - - - - - - - - - #
# What we need to see in logs
#
#

output "access-key-sa-xxx-vm" {
  description = "secret_key for sa-xxx-vm"
  value       = yandex_iam_service_account_static_access_key.static-key-xxx-vm.secret_key
  sensitive   = true
}
