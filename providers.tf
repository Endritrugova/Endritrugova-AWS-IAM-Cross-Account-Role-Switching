provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "aws" {
  access_key = var.access_key_dev
  secret_key = var.secret_key_dev
  alias      = "dev"
}
provider "aws" {
  access_key = var.access_key_prod
  secret_key = var.secret_key_prod
  alias      = "prod"
}