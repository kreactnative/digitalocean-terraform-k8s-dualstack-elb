data "external" "versions" {
  program = ["${path.module}/scripts/versions.sh"]
}
locals {
  image_version = data.external.versions.result["imager_version"]
}
resource "digitalocean_custom_image" "talos" {
  name    = "digital-ocean-amd64"
  url     = "https://github.com/siderolabs/talos/releases/download/${local.image_version}/digital-ocean-amd64.raw.gz"
  regions = [var.region]
}
