provider "yandex" {
  token     = "${var.yacloud-token}"
  # identity cloud
  cloud_id  = "${var.yacloud-cloud-id}"
  # identity catalog
  folder_id = "${var.yacloud-folder-id}"
  # zona dostupnosti po umolchaniu
  zone      = "${var.yacloud-zone-a}"
}