resource "digitalocean_ssh_key" "dummy" {
  name       = "ssh_key"
  public_key = var.ssh_key
}

resource "digitalocean_droplet" "control-plane" {
  depends_on = [digitalocean_ssh_key.dummy, digitalocean_custom_image.talos]
  count      = var.MASTER_COUNT
  name       = "${var.master_name}-${count.index + 1}"
  region     = var.region
  image      = digitalocean_custom_image.talos.image_id
  size       = var.master_size
  tags       = [var.tag_elb_master_name]
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}

resource "digitalocean_droplet" "worker" {
  depends_on = [digitalocean_ssh_key.dummy, digitalocean_custom_image.talos]
  count      = var.WORKER_COUNT
  name       = "${var.worker_name}-${count.index + 1}"
  region     = var.region
  image      = digitalocean_custom_image.talos.image_id
  size       = var.worker_size
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}
