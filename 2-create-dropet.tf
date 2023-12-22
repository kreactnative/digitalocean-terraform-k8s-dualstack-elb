resource "digitalocean_ssh_key" "dummy" {
  name       = "Dummy Talos Key"
  public_key = file("files/id_rsa.pub")
}
