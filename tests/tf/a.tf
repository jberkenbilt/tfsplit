data "local_file" "input" {
  filename = "${path.module}/input"
}

resource "local_file" "single_file" {
  filename = "auto/direct"
  content  = data.local_file.input.content
}

resource "local_file" "count_file" {
  count    = 2
  filename = "auto/direct-${count.index}"
  content  = "count=${count.index}\n"
}

resource "local_file" "foreach_file" {
  for_each = { a : "x", b : "y" }
  filename = "auto/direct-${each.key}-${each.value}"
  content  = "key=${each.key}, value=${each.value}\n"
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
