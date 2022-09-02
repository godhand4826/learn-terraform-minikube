resource "kubernetes_service" "products_api" {
  metadata {
    name = "products-api"
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9090
      target_port = "9090"
    }

    selector = {
      app = "products-api"
    }
  }
}

resource "kubernetes_service_account" "products_api" {
  metadata {
    name = "products-api"
  }
}

resource "kubernetes_config_map" "db_configmap" {
  metadata {
    name = "db-configmap"
  }

  data = {
    config = "{\n  \"db_connection\": \"host=postgres port=5432 user=postgres password=password dbname=products sslmode=disable\",\n  \"bind_address\": \":9090\",\n  \"metrics_address\": \":9103\"\n}\n"
  }
}

resource "kubernetes_deployment" "products_api" {
  metadata {
    name = "products-api"

    labels = {
      app = "products-api"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "products-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "products-api"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject" = "true"

          "prometheus.io/port" = "9102"

          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        volume {
          name = "config"

          config_map {
            name = "db-configmap"

            items {
              key  = "config"
              path = "conf.json"
            }
          }
        }

        container {
          name  = "products-api"
          image = "hashicorpdemoapp/product-api:v0.0.21"

          port {
            container_port = 9090
          }

          port {
            container_port = 9103
          }

          env {
            name  = "CONFIG_FILE"
            value = "/config/conf.json"
          }

          volume_mount {
            name       = "config"
            read_only  = true
            mount_path = "/config"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "9090"
            }

            initial_delay_seconds = 15
            timeout_seconds       = 1
            period_seconds        = 10
            failure_threshold     = 30
          }

          image_pull_policy = "Always"
        }

        service_account_name = "products-api"
      }
    }
  }
}

