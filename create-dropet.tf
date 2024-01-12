resource "digitalocean_ssh_key" "macos_key" {
  name       = "ssh_key"
  public_key = var.ssh_key
}

resource "digitalocean_droplet" "control-plane" {
  depends_on = [digitalocean_ssh_key.macos_key]
  count      = var.MASTER_COUNT
  name       = "${var.master_name}-${count.index + 1}"
  region     = var.region
  image      = var.image_slug
  size       = var.master_size
  #tags       = [var.tag_elb_master_name]
  ssh_keys = [digitalocean_ssh_key.macos_key.fingerprint]
  ipv6     = true
}

resource "digitalocean_droplet" "worker" {
  depends_on = [digitalocean_ssh_key.macos_key]
  count      = var.WORKER_COUNT
  name       = "${var.worker_name}-${count.index + 1}"
  region     = var.region
  image      = var.image_slug
  size       = var.worker_size
  ssh_keys   = [digitalocean_ssh_key.macos_key.fingerprint]
  ipv6       = true
}
