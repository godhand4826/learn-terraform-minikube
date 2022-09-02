resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"

    labels = {
      app = "postgres"
    }
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 5432
      target_port = "5432"
    }

    selector = {
      app = "postgres"
    }
  }
}

resource "kubernetes_service_account" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"

        service = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"

          service = "postgres"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject" = "true"

          "prometheus.io/port" = "9102"

          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        volume {
          name = "pgdata"
          empty_dir {}
        }

        container {
          name  = "postgres"
          image = "hashicorpdemoapp/product-api-db:v0.0.21"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = "products"
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "password"
          }

          volume_mount {
            name       = "pgdata"
            mount_path = "/var/lib/postgresql/data"
          }

          image_pull_policy = "Always"
        }

        service_account_name = "postgres"
      }
    }
  }
}

