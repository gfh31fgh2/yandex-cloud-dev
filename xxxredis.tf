# # - - - - - - - - - #
# # xxxREDIS host
# # - - - - - - - - - #

resource "yandex_mdb_redis_cluster" "xxxredis" {
  name        = "xxxredis"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.xxx-network.id
  sharded     = false
  tls_enabled = true
  description = "Redis for special records"
  persistence_mode    = "ON"
  deletion_protection = true

  security_group_ids  = [ yandex_vpc_security_group.sg-xxxredis.id ]

  config {
    version  = "7.0"
    password = "xxxx"
  }

  resources {
    resource_preset_id = "hm3-c2-m8"
    disk_size          = 16
  }

  maintenance_window {
    type = "WEEKLY"
    hour = 1
    day  = "WED"
  }

  labels    = {
    billingtype = "redis"
  }


  host {
    zone       = "ru-central1-a"
    subnet_id  = yandex_vpc_subnet.xxxxvpc-a.id
    # shard_name = "first"
    assign_public_ip = true
  }

  host {
    zone       = "ru-central1-b"
    subnet_id  = yandex_vpc_subnet.xxxvpc-b.id
    # shard_name = "second"
  }

  # host {
  #   zone       = "ru-central1-c"
  #   subnet_id  = "${yandex_vpc_subnet.baz.id}"
  #   shard_name = "third"
  # }
}

# SG for xxx
resource "yandex_vpc_security_group" "sg-xxxredis" {
  name        = "SG - for xxxredis"
  network_id  = yandex_vpc_network.xxx-network.id

  # ingress {
  #   protocol       = "TCP"
  #   port           = 22
  #   v4_cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    protocol       = "TCP"
    description    = "from local subnet"
    port           = 6379
    v4_cidr_blocks = [ "${var.xxxsubnet1}/24", "${var.xxxsubnet2}/24" ]
  }


  ingress {
    protocol       = "TCP"
    description    = "bastion"
    port           = 6379
    v4_cidr_blocks = ["x/32"]
  }


  ingress {
    protocol       = "TCP"
    description    = "xxx-VPN"
    port           = 6379
    v4_cidr_blocks = ["x/32"]
  }

  # ------- deleted ------- 

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}