resource "digitalocean_ssh_key" "dummy" {
  name       = "Dummy ssh key"
  public_key = var.ssh_key
}

resource "digitalocean_droplet" "control-plane" {
  depends_on = [digitalocean_ssh_key.dummy]
  count      = var.MASTER_COUNT
  name       = "talos-control-plane-${count.index + 1}"
  region     = var.region
  image      = var.image_id
  size       = var.master_size
  tags       = [var.tag_elb_master_name]
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}

resource "digitalocean_droplet" "worker" {
  depends_on = [digitalocean_ssh_key.dummy]
  count      = var.WORKER_COUNT
  name       = "talos-worker-node-${count.index + 1}"
  region     = var.region
  image      = var.image_id
  size       = var.worker_size
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}
