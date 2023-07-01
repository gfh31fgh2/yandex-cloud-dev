terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.84.0"
    }
  }

  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "x-state"
    region     = "ru-central1"
    key        = "tfstate/root.tfstate"
    access_key = "xx"
    secret_key = "xxx"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}
