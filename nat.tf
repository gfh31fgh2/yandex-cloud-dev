# - - - - - - - - - #
# NAT host
# - - - - - - - - - #


data "yandex_compute_image" "nat-instance-ubuntu" {
  family = "nat-instance-ubuntu"
}


resource "yandex_compute_instance" "vm-xxx-a" {

  name        = "vm-xxx-a"
  zone        = "ru-central1-a"
  hostname    = "vm-xxx-a"
  description = "VM-NAT-A"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "nat"
  }

  # service_account_id = yandex_iam_service_account.sa-xxxxxxx.id

  resources {
    cores = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id    = data.yandex_compute_image.nat-instance-ubuntu.id
      description = "Disk root for vm-xxx-a"
      size        = "13"
      type        = "network-ssd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.public-xxx-a.id
    nat                 = true
    nat_ip_address      = "xxx"
  }

  allow_stopping_for_update = true

}

resource "yandex_compute_instance" "vm-xxx-b" {

  name        = "vm-xxx-b"
  zone        = "ru-central1-b"
  hostname    = "vm-xxx-b"
  description = "VM-NAT-B"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "nat"
  }

  resources {
    cores = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id    = data.yandex_compute_image.nat-instance-ubuntu.id
      description = "Disk root for vm-xxx-b"
      size        = "13"
      type        = "network-ssd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.public-xxx-b.id
    nat                 = true
    nat_ip_address      = "xxx"
  }

  allow_stopping_for_update = true

}
