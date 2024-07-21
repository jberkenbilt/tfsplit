locals {
  path = "/tmp/tfsplit-demo/resources"
  regions = ["east", "west"]
}

module "thing" {
  for_each = toset(local.regions)
  source = "../../modules/thing"
  path = local.path
  name = "two"
  region = each.key
}
