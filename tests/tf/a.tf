data "template_file" "single_data" {
  template = "$${key} = $${value}; other=$${other}\n"

  vars = {
    key   = "some key"
    value = "some value"
    other = "some other"
  }
}

resource "local_file" "single_file" {
  filename = "auto/template"
  content  = data.template_file.single_data.rendered
}

resource "local_file" "count_file" {
  count    = 2
  filename = "auto/template-${count.index}"
  content  = data.template_file.single_data.rendered
}

resource "local_file" "foreach_file" {
  for_each = { a : "x", b : "y" }
  filename = "auto/template-${each.key}-${each.value}"
  content  = data.template_file.single_data.rendered
}

output "name" {
  value     = local_file.count_file[0].filename
  sensitive = true
}

module "single_mod" {
  source = "./mod"
  prefix = "mod1"
  key    = "mod1 key"
  value  = "mod1 value"
  other  = "mod1 other"
}

module "count_mod" {
  count  = 1
  source = "./mod"
  prefix = "mod1-${count.index}"
  key    = "mod1 key"
  value  = "mod1 value"
  other  = "mod1 other"
}

module "foreach_mod" {
  for_each = toset(["a"])
  source   = "./mod"
  prefix   = "mod1-${each.key}"
  key      = "mod1 key"
  value    = "mod1 value"
  other    = "mod1 other"
}
