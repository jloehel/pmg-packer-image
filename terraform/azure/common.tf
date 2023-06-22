resource "random_string" "name" {
  length  = 8
  special = false
  number  = false
  upper   = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

output "password" {
  value     = random_password.password.result
  sensitive = true
}
