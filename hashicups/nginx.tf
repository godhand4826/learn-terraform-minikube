resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "nginx"
    }

  }
}

resource "kubernetes_service_account" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_config_map" "nginx_configmap" {
  metadata {
    name = "nginx-configmap"
  }

  data = {
    config = "\n# /etc/nginx/conf.d/default.conf\n  proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC:10m inactive=7d use_temp_path=off;\n\n  upstream frontend_upstream {\n    server frontend:3000;\n  }\n\n  server {\n    listen 80;\n    server_name  localhost;\n\n    server_tokens off;\n\n    gzip on;\n    gzip_proxied any;\n    gzip_comp_level 4;\n    gzip_types text/css application/javascript image/svg+xml;\n\n    proxy_http_version 1.1;\n    proxy_set_header Upgrade $http_upgrade;\n    proxy_set_header Connection 'upgrade';\n    proxy_set_header Host $host;\n    proxy_cache_bypass $http_upgrade;\n\n    location /_next/static {\n      proxy_cache STATIC;\n      proxy_pass http://frontend_upstream;\n\n      # For testing cache - remove before deploying to production\n      # add_header X-Cache-Status $upstream_cache_status;\n    }\n\n    location /static {\n      proxy_cache STATIC;\n      proxy_ignore_headers Cache-Control;\n      proxy_cache_valid 60m;\n      proxy_pass http://frontend_upstream;\n\n      # For testing cache - remove before deploying to production\n      # add_header X-Cache-Status $upstream_cache_status;\n    }\n\n    location / {\n      proxy_pass http://frontend_upstream;\n    }\n\n    location /api {\n      proxy_pass http://public-api:8080;\n    }\n  }\n"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"

    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject" = "true"
        }
      }

      spec {
        volume {
          name = "config"

          config_map {
            name = "nginx-configmap"

            items {
              key  = "config"
              path = "default.conf"
            }
          }
        }

        container {
          name  = "nginx"
          image = "nginx:alpine"

          port {
            container_port = 80
          }

          volume_mount {
            name       = "config"
            read_only  = true
            mount_path = "/etc/nginx/conf.d"
          }

          image_pull_policy = "Always"
        }

        service_account_name = "nginx"
      }
    }
  }
}

