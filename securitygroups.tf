# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Security Groups

# Security bastion host
resource "yandex_vpc_security_group" "group-bastion-host" {
  name        = "My security group bastion host"
  network_id  = yandex_vpc_network.xxx-network.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG for xxx host
resource "yandex_vpc_security_group" "group-xxx-host" {
  name        = "My security group for xxx host"
  network_id  = yandex_vpc_network.xxx-network.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 2222
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 8081
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}



# SG For NFS
resource "yandex_vpc_security_group" "group-nfsrules" {
  name        = "SG - NFSRules"
  network_id  = yandex_vpc_network.xxx-network.id

  ingress {
    protocol       = "TCP"
    description    = "NFS-111-TCP"
    port           = 111
    v4_cidr_blocks = ["x", "x", "x", "x/32"]
  }

  ingress {
    protocol       = "UDP"
    description    = "NFS-111-UDP"
    port           = 111
    v4_cidr_blocks = ["x/24", "x/24", "x/32", "x/32"]
  }

  ingress {
    protocol       = "TCP"
    description    = "NFS-2049-TCP"
    port           = 2049
    v4_cidr_blocks = ["x/24", "x/24", "x/32", "x/32"]
  }

  ingress {
    protocol       = "UDP"
    description    = "NFS-2049-UDP"
    port           = 2049
    v4_cidr_blocks = ["x/24", "x/24", "x/32", "x/32"]
  }

}









# Security group to allow incoming ssh traffic
resource "yandex_vpc_security_group" "group-ssh-traffic" {
  name        = "SG - ssh-local, icmp-local"
  network_id  = yandex_vpc_network.xxx-network.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [ "${var.xxxsubnet1}/24", "${var.xxxsubnet2}/24" ]
  }

  ingress {
    protocol       = "ICMP"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [ "${var.xxxsubnet1}/24", "${var.xxxsubnet2}/24"]
  }
}


# Security group to allow outcoming traffic
resource "yandex_vpc_security_group" "sg-allout" {
  name        = "SG - allout"
  network_id  = yandex_vpc_network.xxx-network.id

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

# Security group to allow incoming ssh traffic from GITLAB RUNNER
resource "yandex_vpc_security_group" "sg-gitlab-1" {
  name        = "SG - gitlab-runner-1"
  network_id  = yandex_vpc_network.xxx-network.id

  ingress {
    protocol       = "TCP"
    description    = "22 - Gitlab Runner 1"
    port           = 22
    v4_cidr_blocks = ["x/32"]
  }
}

# Security group to allow outcoming traffic for Yandex Cloud Logging
resource "yandex_vpc_security_group" "sg-yandex-logs" {
  name        = "SG - yandex cloud logging"
  network_id  = yandex_vpc_network.xxx-network.id

  egress {
    description    = "0-65535 - Yandex Cloud logging"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["x/32"]
  }
}

resource "yandex_vpc_security_group" "sg-frontvms" {
  name        = "SG - frontvms"
  network_id  = yandex_vpc_network.xxx-network.id

  # for healthchecks
  ingress {
    protocol          = "ANY"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [ "${var.xxxsubnet1}/24", "${var.xxxsubnet2}/24" ]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [ "${var.public_xxxsubnet1}/24", "${var.public_xxxsubnet2}/24" ]
  }

  # From xxx
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [ "x/32", "x/32" ]
  }

  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = [ "x/32", "x/32" ]
  }


  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "sg-apivms" {
  name        = "SG - apivms"
  network_id  = yandex_vpc_network.xxx-network.id

  # for healthchecks
  ingress {
    protocol          = "ANY"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [ "${var.xxxsubnet1}/24", "${var.xxxsubnet2}/24" ]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [ "${var.public_xxxsubnet1}/24", "${var.public_xxxsubnet2}/24" ]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}




# Security group for instance inside group
resource "yandex_vpc_security_group" "sg-income-healthcheck-lb" {
  name        = "SG Healthcheck"
  network_id  = yandex_vpc_network.xxx-network.id

  ingress {
    protocol          = "ANY"
    predefined_target = "loadbalancer_healthchecks"
  }

}


# Security group for Cloudflare
resource "yandex_vpc_security_group" "sg-incoming-cloudflare" {
  name        = "SG IncomingCloudflare"
  network_id  = yandex_vpc_network.xxx-network.id

  # Cloudflare IPs - 80 port
  ingress {
    protocol       = "TCP"
    description    = "Cloudflare-80"
    port           = 80
    v4_cidr_blocks = [ "x/17" ]
  }

  # Cloudflare IPs - 443 port
  ingress {
    protocol       = "TCP"
    description    = "Cloudflare-443"
    port           = 443
    v4_cidr_blocks = [ "x/17" ]
  }
}



# Security group for MySQL (xxx)
resource "yandex_vpc_security_group" "mysql-sg" {
  name       = "SG mysql-xxxdb"
  network_id = yandex_vpc_network.xxx-network.id

  ingress {
    description    = "MySQL from xxxnetwork"
    protocol       = "TCP"
    port           = 3306
    v4_cidr_blocks = [ "${var.xxxsubnet1}/24", "${var.xxxsubnet2}/24" ]
  }

  ingress {
    description    = "MySQL from xxxxxx"
    protocol       = "TCP"
    port           = 3306
    v4_cidr_blocks = [ "x/32", "x/32" ]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}




