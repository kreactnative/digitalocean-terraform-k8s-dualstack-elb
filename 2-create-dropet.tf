resource "digitalocean_ssh_key" "dummy" {
  name       = "Dummy ssh key"
  public_key = file("files/id_rsa.pub")
}

resource "digitalocean_droplet" "control-plane" {
  depends_on = [digitalocean_ssh_key.dummy]
  count      = 3
  name       = "talos-control-plane-${count.index + 1}"
  region     = var.region
  image      = "146722313"
  size       = "s-2vcpu-4gb"
  tags       = ["talos-digital-ocean-control-plane"]
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}

resource "digitalocean_droplet" "worker" {
  depends_on = [digitalocean_ssh_key.dummy]
  count      = 3
  name       = "talos-worker-node-${count.index + 1}"
  region     = var.region
  image      = "146722313"
  size       = "s-2vcpu-4gb"
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}
