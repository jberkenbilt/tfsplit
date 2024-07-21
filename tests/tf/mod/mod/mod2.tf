variable "key" {}
variable "value" {}
variable "other" {}
variable "prefix" {}

data "local_file" "input" {
  filename = "${path.module}/input"
}

resource "local_file" "mod2_single_file" {
  filename = "auto/mod2-${var.prefix}-single"
  content  = "mod2: prefix=${var.prefix}: ${data.local_file.input.content}"
}

resource "local_file" "mod2_count_file" {
  count    = 2
  filename = "auto/mod2-${var.prefix}-${count.index}"
  content  = "mod2: prefix=${var.prefix}, count=${count.index}\n"
}

resource "local_file" "mod2_foreach_file" {
  for_each = { a : "x", b : "y" }
  filename = "auto/mod2-${var.prefix}-${each.key}-${each.value}"
  content  = "mod2: prefix=${var.prefix}, key=${each.key}, value=${each.value}\n"
}
