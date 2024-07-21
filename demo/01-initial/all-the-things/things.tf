locals {
  path = "/tmp/tfsplit-demo/resources"
}

module "thing-one-east" {
  source = "../modules/thing"
  path = local.path
  name = "one"
  region = "east"
}

module "thing-one-west" {
  source = "../modules/thing"
  path = local.path
  name = "one"
  region = "west"
}

module "thing-two-east" {
  source = "../modules/thing"
  path = local.path
  name = "two"
  region = "east"
}

module "thing-two-west" {
  source = "../modules/thing"
  path = local.path
  name = "two"
  region = "west"
}
