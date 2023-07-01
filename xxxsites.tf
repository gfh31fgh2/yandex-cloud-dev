# - - - - - - - - - #
# xxx host
# - - - - - - - - - #

resource "yandex_compute_instance" "xxx-v2" {

  name        = "xxx-v2"
  zone        = "ru-central1-a"
  hostname    = "xxx-v2"
  description = "xxx"
  platform_id = "standard-v3"

  labels    = {
    billingtype = "xxx"
  }

  service_account_id = "xxxx"

  resources {
    cores = 2
    memory = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id    = "${var.ubuntu_family_image_id}"
      description = "Disk for the xxx"
      size        = 100
      type        = "network-hdd"
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.xxxvpc-a.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.group-xxx-host.id]
    nat_ip_address      = "x"
  }

 
  allow_stopping_for_update = true

  metadata = {
    user-data = file("${path.module}/yaml/xxx.yaml")
    # after deploy - you need to execute ansible scripts! xxx
  }
}
