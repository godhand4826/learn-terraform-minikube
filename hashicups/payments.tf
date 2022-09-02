resource "kubernetes_service" "payments" {
  metadata {
    name = "payments"
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 1800
      target_port = "8080"
    }

    selector = {
      app = "payments"
    }
  }
}

resource "kubernetes_service_account" "payments" {
  metadata {
    name = "payments"
  }
}

resource "kubernetes_deployment" "payments" {
  metadata {
    name = "payments"

    labels = {
      app = "payments"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "payments"
      }
    }

    template {
      metadata {
        labels = {
          app = "payments"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject" = "true"
        }
      }

      spec {
        container {
          name  = "payments"
          image = "hashicorpdemoapp/payments:v0.0.16"

          port {
            container_port = 8080
          }

          image_pull_policy = "Always"
        }

        service_account_name = "payments"
      }
    }
  }
}

