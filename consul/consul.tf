terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
  }
}

variable "consul_namespace" {
  description = "name of the consul namespace"
  type        = string
  default     = "consul"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "consul" {
  metadata {
    name = var.consul_namespace
  }
}

# consul couldn't specify namespace without enterprise.
resource "kubernetes_labels" "connect-inject-enabled" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "default"
  }
  labels = {
    "connect-inject" = "enabled"
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "0.47.1"

  namespace        = var.consul_namespace
  values           = ["${file("consul_values.yaml")}"]

  depends_on = [ kubernetes_namespace.consul ]
}
