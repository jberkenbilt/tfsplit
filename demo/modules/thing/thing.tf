resource "local_file" "thing" {
  filename = "${var.path}/${var.region}/thing-${var.name}"
  content  = "name=${var.name}, region=${var.region}\n"
}
