variable "key" {}
variable "value" {}
variable "other" {}
variable "prefix" {}

data "template_file" "mod_single_data" {
  template = "$${key} = $${value}; other=$${other}\n"

  vars = {
    key   = var.key
    value = var.value
    other = var.other
  }
}

resource "local_file" "mod_single_file" {
  filename = "auto/${var.prefix}"
  content  = data.template_file.mod_single_data.rendered
}

resource "local_file" "mod_count_file" {
  count    = 2
  filename = "auto/${var.prefix}-${count.index}"
  content  = data.template_file.mod_single_data.rendered
}

resource "local_file" "mod_foreach_file" {
  for_each = { a : "x", b : "y" }
  filename = "auto/${var.prefix}-${each.key}-${each.value}"
  content  = data.template_file.mod_single_data.rendered
}

output "name" {
  value     = local_file.mod_count_file[0].filename
  sensitive = true
}

module "mod_single_mod" {
  source = "./mod"
  prefix = "mod2"
  key    = "mod2 key"
  value  = "mod2 value"
  other  = "mod2 other"
}

module "mod_count_mod" {
  count  = 1
  source = "./mod"
  prefix = "mod2-${count.index}"
  key    = "mod2 key"
  value  = "mod2 value"
  other  = "mod2 other"
}

module "mod_foreach_mod" {
  for_each = toset(["a"])
  source   = "./mod"
  prefix   = "mod2-${each.key}"
  key      = "mod2 key"
  value    = "mod2 value"
  other    = "mod2 other"
}
