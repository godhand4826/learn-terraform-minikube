resource "kubernetes_service" "public_api" {
  metadata {
    name = "public-api"

    labels = {
      app = "public-api"
    }
  }

  spec {
    port {
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "public-api"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_account" "public_api" {
  metadata {
    name = "public-api"
  }
}

resource "kubernetes_deployment" "public_api" {
  metadata {
    name = "public-api"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "public-api"

        service = "public-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "public-api"

          service = "public-api"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject" = "true"

          "prometheus.io/port" = "9102"

          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        container {
          name  = "public-api"
          image = "hashicorpdemoapp/public-api:v0.0.6"

          port {
            container_port = 8080
          }

          env {
            name  = "BIND_ADDRESS"
            value = ":8080"
          }

          env {
            name  = "PRODUCT_API_URI"
            value = "http://products-api:9090"
          }

          env {
            name  = "PAYMENT_API_URI"
            value = "http://payments:1800"
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "jaeger-agent"
          image = "jaegertracing/jaeger-agent:latest"
          args  = ["--reporter.grpc.host-port=dns:///jaeger-collector-headless.default:14250", "--reporter.type=grpc"]

          port {
            name           = "zk-compact-trft"
            container_port = 5775
            protocol       = "UDP"
          }

          port {
            name           = "config-rest"
            container_port = 5778
            protocol       = "TCP"
          }

          port {
            name           = "jg-compact-trft"
            container_port = 6831
            protocol       = "UDP"
          }

          port {
            name           = "jg-binary-trft"
            container_port = 6832
            protocol       = "UDP"
          }

          port {
            name           = "admin-http"
            container_port = 14271
            protocol       = "TCP"
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "public-api"
      }
    }
  }
}

