resource "consul_config_entry" "public-api-intention" {
  name = "public-api"
  kind = "service-intentions"
  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "nginx"
        Precedence = 9
        Type       = "consul"
      },
    ]
  })
}

resource "consul_config_entry" "products-api-intention" {
  name = "products-api"
  kind = "service-intentions"
  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "public-api"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "payments-intention" {
  name = "payments"
  kind = "service-intentions"
  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "public-api"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "postgres-intention" {
  name = "postgres"
  kind = "service-intentions"
  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "products-api"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "frontend-intention" {
  name = "frontend"
  kind = "service-intentions"
  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "nginx"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "default-deny-intention" {
  name = "*"
  kind = "service-intentions"
  config_json = jsonencode({
    Sources = [
      {
        Action     = "deny"
        Name       = "*"
        Precedence = 5
        Type       = "consul"
      }
    ]
  })
}
