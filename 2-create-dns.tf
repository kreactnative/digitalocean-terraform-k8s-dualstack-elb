resource "digitalocean_domain" "default" {
  name = var.domain_name
}
resource "digitalocean_record" "ipv4" {
  domain = digitalocean_domain.default.id
  type   = "A"
  name   = "*."
  value  = digitalocean_droplet.control-plane[0].ipv4_address
}
resource "digitalocean_record" "ipv6" {
  domain = digitalocean_domain.default.id
  type   = "AAAA"
  name   = "*."
  #value  = digitalocean_droplet.control-plane[0].ipv6_address
  value = format("%s%s", substr(digitalocean_droplet.control-plane[0].ipv6_address, 0, length(digitalocean_droplet.control-plane[0].ipv6_address) - 1), "5")
}
