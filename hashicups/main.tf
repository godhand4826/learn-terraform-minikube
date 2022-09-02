terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "2.15.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "consul" {
  datacenter = "single-datacenter"
}
