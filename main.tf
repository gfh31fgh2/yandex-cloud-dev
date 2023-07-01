# data "yandex_compute_image" "container-optimized-image" {
#   family = "container-optimized-image"
# }

resource "yandex_compute_instance_group" "xxxxxscalegroup" {
  name         = "xxxxxscalegroup"
  description  = "Group of instances with docker (nginx + php) based on coi"
  labels  = {
    billingtype = "ig"
  }
  folder_id = "${var.yacloud-folder-id}"
  service_account_id = "${yandex_iam_service_account.sa-xxxxx.id}"

  instance_template {
    platform_id = "standard-v3"
    name = "xxxxx-docker-{instance.index}"

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id    = data.yandex_compute_image.container-optimized-image.id
        description = "Disk for the root"
        size        = "30"
        type        = "network-hdd"
      }
    }

    # secondary_disk {
    #   mode = "READ_WRITE"
    #   disk_id = "xxxx"
    #   # device_name = yandex_compute_disk.disk1.name
    # }

    network_interface {
      subnet_ids = [ "${yandex_vpc_subnet.xvpc-a.id}", "${yandex_vpc_subnet.xvpc-b.id}" ]
      nat = false
      security_group_ids = [ yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.xxigsg.id]
    }

    metadata = {
      docker-compose = file("${path.module}/yaml/declaration_compose.yaml")
      user-data = file("${path.module}/yaml/xxxxxscalegroup_cloud_config.yaml")
      serial-port-enable = 1
    }

    labels = {
      version = "1.0.1"
    }

    service_account_id = "${yandex_iam_service_account.sa-xxxxx.id}"
  }

  scale_policy {
    auto_scale {
      initial_size            = 2
      measurement_duration    = 60
      cpu_utilization_target  = 80
      min_zone_size           = 1
      max_size                = 3
      warmup_duration         = 60
      stabilization_duration  = 120
    }
  }

  health_check {
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
    healthy_threshold   = 2
    http_options {
      port = 80
      path = "/health.php"
    }
  }
  max_checking_health_duration = 60

  allocation_policy {
    zones = [ "${yandex_vpc_subnet.xvpc-a.zone}", "${yandex_vpc_subnet.xvpc-b.zone}" ]
  }

  # application_load_balancer {
  #   target_group_name = "xxxxx-albtarget-group2"
  # }

  load_balancer {
    target_group_name = "xxxxx-nlbtarget-group"
  }

  deploy_policy {
    max_unavailable   = 1
    max_creating      = 2
    max_expansion     = 4
    max_deleting      = 2
    strategy          = "proactive"
    startup_duration  = 60
  }

}

resource "yandex_logging_group" "xxxxx-cnt-grp" {
  name      = "xxxxx-cnt-grp"
  folder_id = "${var.yacloud-folder-id}"
}


#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts
#

resource "yandex_iam_service_account" "sa-xxxxx" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxxxx"
}


resource "yandex_iam_service_account" "sa-xapi" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xapi"
}

#
# - - - - - - - - - #
# Create Static Access Keys for key-xapi
# - - - - - - - - - #
#
resource "yandex_iam_service_account_static_access_key" "static-key-xapi" {
  service_account_id = yandex_iam_service_account.sa-xapi.id
  description        = "static access key for sa-xapi account"
}

resource "yandex_iam_service_account_static_access_key" "static-key-xxxxx" {
  service_account_id = yandex_iam_service_account.sa-xxxxx.id
  description        = "static access key for sa-xxxxx account"
}


resource "yandex_resourcemanager_folder_iam_member" "sa-xapi-iam-member" {

  for_each  = toset([
    "compute.images.user",
    "editor",
    "vpc.securityGroups.user",
    "container-registry.images.puller",
    "vpc.user",
    "kms.keys.encrypterDecrypter",
    "logging.writer",
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xapi.id}"
}


resource "yandex_resourcemanager_folder_iam_member" "sa-xxxxx-iam-member" {

  for_each  = toset([
    "compute.images.user",
    "editor",
    "vpc.securityGroups.user",
    "container-registry.images.puller",
    "vpc.user",
    "kms.keys.encrypterDecrypter",
    "logging.writer",
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xxxxx.id}"
}


#
# - - - - - - - - - #
# xapi Scale Group (xapiscalegroup)
# - - - - - - - - - #
#
#
resource "yandex_compute_instance_group" "xapiscalegroup" {
  name         = "xapiscalegroup"
  description  = "Group of instances with docker (nginx + php) for xapi"
  labels  = {
    billingtype = "ig"
  }
  folder_id = "${var.yacloud-folder-id}"
  service_account_id = "${yandex_iam_service_account.sa-xapi.id}"

  instance_template {
    platform_id = "standard-v3"
    name = "xapi-docker-{instance.index}"

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id    = data.yandex_compute_image.container-optimized-image.id
        description = "Disk for the root"
        size        = "30"
        type        = "network-hdd"
      }
    }

    network_interface {
      subnet_ids = [ "${yandex_vpc_subnet.xvpc-a.id}", "${yandex_vpc_subnet.xvpc-b.id}" ]
      nat = false
      security_group_ids = [ yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.xxxigapisg.id]
    }

    metadata = {
      docker-compose = file("${path.module}/yaml/xapi_declaration_compose.yaml")
      user-data = file("${path.module}/yaml/xapi_cloud_config.yaml")
      serial-port-enable = 1
    }

    labels = {
      version = "1.0.1"
    }

    service_account_id = "${yandex_iam_service_account.sa-xapi.id}"
  }

  scale_policy {
    auto_scale {
      initial_size            = 2
      measurement_duration    = 60
      cpu_utilization_target  = 80
      min_zone_size           = 1
      max_size                = 3
      warmup_duration         = 60
      stabilization_duration  = 120
    }
  }

  health_check {
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
    healthy_threshold   = 2
    http_options {
      port = 80
      path = "/health.php"
    }
  }
  max_checking_health_duration = 60

  allocation_policy {
    zones = [ "${yandex_vpc_subnet.xvpc-a.zone}", "${yandex_vpc_subnet.xvpc-b.zone}" ]
  }

  application_load_balancer {
    target_group_name = "xapi-albtarget-group"
  }

  deploy_policy {
    max_unavailable   = 1
    max_creating      = 2
    max_expansion     = 4
    max_deleting      = 2
    strategy          = "proactive"
    startup_duration  = 60
  }

}

output "xxxxxscalegroup_external_ip" {
  value = [yandex_compute_instance_group.xxxxxscalegroup.instances[*].network_interface[0].nat_ip_address]
}

output "xapiscalegroup_external_ip" {
  value = [yandex_compute_instance_group.xapiscalegroup.instances[*].network_interface[0].nat_ip_address]
}

output "access-key-sa-xapi" {
  description = "secret_key for sa-xapi"
  value       = yandex_iam_service_account_static_access_key.static-key-xapi.secret_key
  sensitive   = true
}




#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts
#

resource "yandex_iam_service_account" "sa-xxservice-vm" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxservice-vm"
}


#
# - - - - - - - - - #
# Static Access Keys
# - - - - - - - - - #
# Create Static Access Keys
#

resource "yandex_iam_service_account_static_access_key" "static-key-xxservice-vm" {
  service_account_id = yandex_iam_service_account.sa-xxservice-vm.id
  description        = "static access key for sa-xxservice-vm account"
}


#
# - - - - - - - - - #
# IAM Member
# - - - - - - - - - #
# Create IAM member with rights for xxxxx1VM
#

resource "yandex_resourcemanager_folder_iam_member" "sa-xxservice-vm-iam-member" {

  for_each  = toset([
    "compute.images.user",
    "editor",
    "vpc.securityGroups.user",
    "vpc.user",
    "kms.keys.encrypterDecrypter",
    "logging.writer",
    "storage.admin",
    "vpc.admin"
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xxservice-vm.id}"
}



#
# - - - - - - - - - #
# xxservice-VM3
# - - - - - - - - - #
# Create VM
#

resource "yandex_compute_instance" "xxservice-vm3" {

  name        = "xxservice-vm3"
  zone        = "ru-central1-a"
  hostname    = "xxservice-vm3"
  description = "xxservice3"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "services"
  }

  service_account_id = yandex_iam_service_account.sa-xxservice-vm.id

  resources {
    cores = 2
    memory = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_lts_22}"
      description = "xxservice-disk"
      size        = 70
      type        = "network-hdd"
    }
  }

  secondary_disk {
    disk_id       = "xxxx"
    auto_delete   = false
    mode          = "READ_WRITE"
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.xvpc-a.id
    nat                 = true
    security_group_ids  = [ yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.sg-income-healthcheck-lb.id, yandex_vpc_security_group.sg-incoming-home.id, yandex_vpc_security_group.sg-allout.id, yandex_vpc_security_group.group-nfsrules.id ]
    nat_ip_address  = "x"
    ip_address      = "x"
  }
 
  allow_stopping_for_update = true

  metadata = {
    user-data = file("${path.module}/yaml/xxservice.yaml")
  }
}


#
# - - - - - - - - - #
# KMS Key for Yandex Lockbox
# - - - - - - - - - #
#
resource "yandex_kms_symmetric_key" "lockbox-kmskey1" {
  name              = "lockbox-kmskey1"
  description       = "KMS key for encrypting files for lockbox"
  default_algorithm = "AES_256"
  # rotation_period   = "8760h" // equal to 1 year
  lifecycle {
    prevent_destroy = true
  }
}

#
# - - - - - - - - - #
# Lockbox secret for yandex cloud functions
# - - - - - - - - - #
#
resource "yandex_lockbox_secret" "ycf-secret" {
  name = "ycf-secret"
  deletion_protection = true
  description = "secret key for yandex cloud functions"
  kms_key_id = yandex_kms_symmetric_key.lockbox-kmskey1.id
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

output "access-key-sa-xxservice-vm" {
  description = "secret_key for sa-xxservice-vm"
  value       = yandex_iam_service_account_static_access_key.static-key-xxservice-vm.secret_key
  sensitive   = true
}
