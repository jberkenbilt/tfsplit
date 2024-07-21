terraform {
  backend "local" {
    path = "/tmp/tfsplit-demo/state/all-the-things/terraform.tfstate"
  }
}
