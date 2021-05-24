provider "aws" {
  region = var.region
}

module "remote_state" {
  source      = "github.com/andrewmpalka/tf_remote_state.git"
  prefix      = var.prefix
  environment = var.environment
}