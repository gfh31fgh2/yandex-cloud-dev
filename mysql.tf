# - - - - - - - - - #
# Yandex Managed Service for MySQL
# - - - - - - - - - #

resource "yandex_mdb_mysql_cluster" "xxxmysql-cluster" {
  name                = "xxxmysql-cluster"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.xxx-network.id
  version             = "8.0"
  security_group_ids  = [ yandex_vpc_security_group.mysql-sg.id ]
  deletion_protection = true

  resources {
    resource_preset_id = "m3-c2-m16"
    disk_type_id       = "network-ssd"
    disk_size          = 50
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.xxxxvpc-a.id
    assign_public_ip = true
  }

  # host {
  #   zone      = "ru-central1-b"
  #   subnet_id = yandex_vpc_subnet.xxvpc-b.id
  #   assign_public_ip = true
  # }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 1
  }

  access {
    data_lens = true
    web_sql = true
  }
  performance_diagnostics {
    enabled                       = true
    sessions_sampling_interval    = 5
    statements_sampling_interval  = 60
  }
}

resource "yandex_mdb_mysql_database" "xxxxdb" {
  cluster_id = yandex_mdb_mysql_cluster.xxmysql-cluster.id
  name       = "xxxxdb"
}

resource "yandex_mdb_mysql_user" "xxxstatuser" {
    cluster_id = yandex_mdb_mysql_cluster.xxmysql-cluster.id
    name       = "xxxxuser"
    password   = "xxx"

    permission {
      database_name = yandex_mdb_mysql_database.xxxstatdb.name
      roles         = ["ALL"]
    }

    # connection_limits {
    #   max_questions_per_hour   = 5000000
    #   max_updates_per_hour     = 5000000
    #   max_connections_per_hour = 5000000
    #   max_user_connections     = 5000
    # }
    connection_limits {
      max_questions_per_hour   = 0
      max_updates_per_hour     = 0
      max_connections_per_hour = 0
      max_user_connections     = 0
    }

    global_permissions = ["PROCESS"]

    authentication_plugin = "SHA256_PASSWORD"
}


resource "yandex_mdb_mysql_user" "xxxstatuser2" {
    cluster_id = yandex_mdb_mysql_cluster.xxmysql-cluster.id
    name       = "xxx"
    password   = "xxx"

    permission {
      database_name = yandex_mdb_mysql_database.xxxxstatdb.name
      roles         = ["ALL"]
    }

    connection_limits {
      max_questions_per_hour   = 0
      max_updates_per_hour     = 0
      max_connections_per_hour = 0
      max_user_connections     = 0
    }

    global_permissions = ["PROCESS"]

    authentication_plugin = "CACHING_SHA2_PASSWORD"
}


output "db_cluster_hosts_fqdn" {
  value = yandex_mdb_mysql_cluster.xxmysql-cluster.host.*.fqdn
}

output "db_cluster_master" {
  value = "c-${yandex_mdb_mysql_cluster.xxmysql-cluster.id}.rw.mdb.yandexcloud.net"
}