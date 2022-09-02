resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    labels = {
      app = "frontend"
    }
  }

  spec {
    port {
      port        = 3000
      target_port = "3000"
    }

    selector = {
      app = "frontend"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_account" "frontend" {
  metadata {
    name = "frontend"
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "frontend"

        service = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"

          service = "frontend"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject" = "true"

          "prometheus.io/port" = "9102"

          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = "hashicorpdemoapp/frontend:v1.0.3"

          port {
            container_port = 3000
          }

          env {
            name  = "NEXT_PUBLIC_PUBLIC_API_URL"
            value = "/"
          }

          image_pull_policy = "Always"
        }

        service_account_name = "frontend"
      }
    }
  }
}

