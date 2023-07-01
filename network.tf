resource "yandex_vpc_network" "xxx-network" {
  name = "xxx-network"
}

resource "yandex_vpc_subnet" "xxx-a" {
  network_id = yandex_vpc_network.xxx-network.id

  name = "xxx-a"
  zone = "ru-central1-a"

  v4_cidr_blocks = ["${var.xxxsubnet1}/24"]
  route_table_id = yandex_vpc_route_table.via-nat-a.id
}

resource "yandex_vpc_subnet" "public-xxx-a" {
  network_id = yandex_vpc_network.xxx-network.id
  name = "public-xxx-a"
  zone = "ru-central1-a"
  v4_cidr_blocks = ["${var.public_xxxsubnet1}/24"]
}

resource "yandex_vpc_subnet" "public-xxx-b" {
  network_id = yandex_vpc_network.xxx-network.id
  name = "public-xxx-b"
  zone = "ru-central1-b"
  v4_cidr_blocks = ["${var.public_xxxsubnet2}/24"]
}

resource "yandex_vpc_subnet" "xxx-b" {
  network_id = yandex_vpc_network.xxx-network.id

  name = "xxx-b"
  zone = "ru-central1-b"

  v4_cidr_blocks = ["${var.xxxsubnet2}/24"]
  route_table_id = yandex_vpc_route_table.via-nat-b.id
}

resource "yandex_vpc_subnet" "xxx-c" {
  network_id = yandex_vpc_network.xxx-network.id

  name = "xxx-c"
  zone = "ru-central1-c"

  v4_cidr_blocks = ["${var.xxxsubnet3}/24"]
  route_table_id = yandex_vpc_route_table.via-nat-b.id
}

# static route, napravlayushii ves ishodyashii traffic A seti v NAT instance
resource "yandex_vpc_route_table" "via-nat-a" {
  network_id = yandex_vpc_network.xxx-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.vm-xxxnat-a.network_interface.0.ip_address
  }
}

# static route, napravlayushii ves ishodyashii traffic B seti v NAT instance
resource "yandex_vpc_route_table" "via-nat-b" {
  network_id = yandex_vpc_network.xxx-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.vm-xxxnat-b.network_interface.0.ip_address
  }
}