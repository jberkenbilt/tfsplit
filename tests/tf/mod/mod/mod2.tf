variable "key" {}
variable "value" {}
variable "other" {}
variable "prefix" {}

data "template_file" "mod2_single_data" {
  template = "$${key} = $${value}; other=$${other}\n"

  vars = {
    key   = var.key
    value = var.value
    other = var.other
  }
}

resource "local_file" "mod2_single_file" {
  filename = "auto/${var.prefix}"
  content  = data.template_file.mod2_single_data.rendered
}

resource "local_file" "mod2_count_file" {
  count    = 2
  filename = "auto/${var.prefix}-${count.index}"
  content  = data.template_file.mod2_single_data.rendered
}

resource "local_file" "mod2_foreach_file" {
  for_each = { a : "x", b : "y" }
  filename = "auto/${var.prefix}-${each.key}-${each.value}"
  content  = data.template_file.mod2_single_data.rendered
}

output "name" {
  value     = local_file.mod2_count_file[0].filename
  sensitive = true
}
