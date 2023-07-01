# - - - - - - - - - #
# Yandex Managed Service for MySQL
# - - - - - - - - - #

resource "yandex_mdb_mysql_cluster" "xxx-mysql-cluster57" {
  name                = "xxx-mysql-cluster57"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.xxx-network.id
  version             = "5.7"
  security_group_ids  = [ yandex_vpc_security_group.mysql-xxx-sg.id ]
  deletion_protection = true

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.xxx-a.id
  }


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

resource "yandex_mdb_mysql_database" "xxxx" {
  cluster_id = yandex_mdb_mysql_cluster.xxx-mysql-cluster57.id
  name       = "xxxx"
}

resource "yandex_mdb_mysql_user" "nuser" {
    cluster_id = yandex_mdb_mysql_cluster.xxx-mysql-cluster57.id
    name       = "xxxx"
    password   = "xxxx"

    permission {
      database_name = yandex_mdb_mysql_database.xxxx.name
      roles         = ["ALL"]
    }

    # connection_limits {
    #   max_questions_per_hour   = 5000
    #   max_updates_per_hour     = 5000
    #   max_connections_per_hour = 5000
    #   max_user_connections     = 1000
    # }

    global_permissions = ["PROCESS"]

    authentication_plugin = "SHA256_PASSWORD"
}

resource "yandex_mdb_mysql_database" "xxx" {
  cluster_id = yandex_mdb_mysql_cluster.xxx-mysql-cluster57.id
  name       = "xxx"
}

resource "yandex_mdb_mysql_user" "nlkt" {
    cluster_id = yandex_mdb_mysql_cluster.xxx-mysql-cluster57.id
    name       = "xxx"
    password   = "xxx"

    permission {
      database_name = yandex_mdb_mysql_database.xxx.name
      roles         = ["ALL"]
    }

    # connection_limits {
    #   max_questions_per_hour   = 5000
    #   max_updates_per_hour     = 5000
    #   max_connections_per_hour = 5000
    #   max_user_connections     = 1000
    # }

    global_permissions = ["PROCESS"]

    authentication_plugin = "SHA256_PASSWORD"
}


output "db_xxx_cluster_hosts_fqdn" {
  value = yandex_mdb_mysql_cluster.xxx-mysql-cluster57.host.*.fqdn
}

output "db_xxx_cluster_master" {
  value = "c-${yandex_mdb_mysql_cluster.xxx-mysql-cluster57.id}.rw.mdb.yandexcloud.net"
}