# - - - - - - - - - - - - - - #
# Mail xxx  host
# - - - - - - - - - - - - - - #



#
# - - - - - - - - - - - - - - #
# Network dvpc
# - - - - - - - - - - - - - - #
#

resource "yandex_vpc_network" "xxdedicated-network" {
  name = "xxdedicated-network"
}

resource "yandex_vpc_subnet" "dvpc-a" {
  network_id = yandex_vpc_network.xxdedicated-network.id

  name = "dvpc-a"
  zone = "ru-central1-a"

  v4_cidr_blocks = ["${var.dedicsubnet1}/24"]
  # route_table_id = yandex_vpc_route_table.via-nat-a.id
}



resource "yandex_vpc_security_group" "xxxxmailhost-sg" {
  name        = "SG for xxx Mailhost"
  network_id  = yandex_vpc_network.xxdedicated-network.id

  ingress {
    protocol       = "ICMP"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [ "${var.dedicsubnet1}/24"]
  }

  # 25
  ingress {
    protocol       = "TCP"
    description    = "25 (TCP)"
    port           = 25
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # ---------------------
  # deleted 
  # ---------------------

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

#
# - - - - - - - - - - - - - - #
# Service Accounts
# - - - - - - - - - - - - - - #
# Create SA accounts
#
resource "yandex_iam_service_account" "sa-xxxxmailhost" {
  folder_id = "${var.yacloud-folder-id}"
  name      = "sa-xxxxmailhost"
}

# - - - - - - - - - - - - - - #
# xxxxmailhost instance
# - - - - - - - - - - - - - - #
resource "yandex_compute_instance" "xxxxmailhost" {

  name        = "xxxxmailhost"
  zone        = "ru-central1-a"
  hostname    = "xxxxmailhost"
  description = "xxx Mailhost"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "mail"
  }

  service_account_id = yandex_iam_service_account.sa-xxxxmailhost.id

  resources {
    cores = 2
    memory = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_lts_22}"
      description = "Disk for the xxxxmailhost"
      size        = 300
      type        = "network-hdd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.dvpc-a.id
    nat                 = true
    security_group_ids  = [ yandex_vpc_security_group.xxxxmailhost-sg.id ]
    nat_ip_address      = "xx"
    ip_address          = "xxx"
  }

  allow_stopping_for_update = true

  metadata = {
    user-data = file("${path.module}/yaml/xxxxmailhost.yaml")
  }
}
