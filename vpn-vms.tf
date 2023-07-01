#
# - - - - - - - - - - - - - - #
# Network for VPN
# - - - - - - - - - - - - - - #
#

resource "yandex_vpc_network" "xx-network" {
  name = "xxx-network"
}

resource "yandex_vpc_subnet" "dvpcvpn-a" {
  network_id = yandex_vpc_network.xx-network.id

  name = "xx-a"
  zone = "ru-central1-a"

  v4_cidr_blocks = ["${var.vpndedicsubnet1}/24"]
}

#
# - - - - - - - - - #
# Service Accounts
# - - - - - - - - - #
# Create SA accounts
#

resource "yandex_iam_service_account" "sa-xx-vm" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xx-vm"
}



#
# - - - - - - - - - #
# Family for openvpn
# - - - - - - - - - #
# Create Static Access Keys
#

data "yandex_compute_image" "openvpn-yandex-instance" {
  family = "openvpn"
}

#
# - - - - - - - - - #
# Static Access Keys
# - - - - - - - - - #
# Create Static Access Keys
#

resource "yandex_iam_service_account_static_access_key" "static-key-xx-vm" {
  service_account_id = yandex_iam_service_account.sa-xx-vm.id
  description        = "static access key for sa-xx-vm account"
}


#
# - - - - - - - - - #
# IAM Member
# - - - - - - - - - #
# Create IAM member with rights for xx
#

resource "yandex_resourcemanager_folder_iam_member" "sa-xx-vm-iam-member" {
  # folder_id = "${var.yacloud-folder-id}"
  # role      = "editor"
  # member    = "serviceAccount:${yandex_iam_service_account.sa-xx.id}"

  for_each  = toset([
    "compute.images.user",
    "vpc.securityGroups.user",
    "vpc.user",
    "logging.writer"
  ])
  folder_id = "${var.yacloud-folder-id}"
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.sa-xx-vm.id}"
}



#
# - - - - - - - - - #
# xxx-A-VM1
# - - - - - - - - - #
# Create VM
#

resource "yandex_compute_instance" "xx-a-vm1" {

  name        = "xx-a-vm1"
  zone        = "ru-central1-a"
  hostname    = "xx-a-vm1"
  description = "VPN-vm-a1"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "vpn"
  }

  service_account_id = yandex_iam_service_account.sa-xx-vm.id

  resources {
    cores = 2
    memory = 2
    core_fraction = 50
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id    = "${var.ubuntu_lts_20}"
      description = "xx-a1-disk"
      size        = 23
      type        = "network-ssd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.dvpcvpn-a.id
    nat                 = true
    security_group_ids  = [ yandex_vpc_security_group.xx-sg.id ]
    nat_ip_address      = "x"
    ip_address          = "x"
  }

  allow_stopping_for_update = true

  metadata = {
    user-data = file("${path.module}/yaml/xx.yaml")
  }
}



#
# - - - - - - - - - - - - - - #
# Security groups
# - - - - - - - - - - - - - - #
#

resource "yandex_vpc_security_group" "xx-sg" {
  name        = "SG for xx VPN"
  network_id  = yandex_vpc_network.xx-network.id

  ingress {
    protocol       = "ICMP"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [ "${var.xx}/24"]
  }

  # 22 - for ssh
  ingress {
    protocol       = "TCP"
    description    = "22 (TCP)"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }



  # 80 - for administration
  ingress {
    protocol       = "TCP"
    description    = "x"
    port           = 80
    v4_cidr_blocks = ["x"]
  }

  ....

  ingress {
    protocol       = "TCP"
    description    = "x"
    port           = 443
    v4_cidr_blocks = ["x"]
  }


  # 1194 - for client connections
  ingress {
    protocol       = "UDP"
    description    = "1194 (UDP)"
    port           = 1194
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "1194 (TCP)"
    port           = 1194
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # outside
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
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

output "access-key-sa-xx-vm" {
  description = "secret_key for sa-xx-vm"
  value       = yandex_iam_service_account_static_access_key.static-key-xx-vm.secret_key
  sensitive   = true
}
