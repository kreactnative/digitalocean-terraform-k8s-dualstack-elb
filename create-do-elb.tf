resource "digitalocean_loadbalancer" "public" {
  name   = var.loadbalancer_name
  region = var.region

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "tcp"

    target_port     = 6443
    target_protocol = "tcp"
  }

  healthcheck {
    port                     = 6443
    protocol                 = "tcp"
    check_interval_seconds   = 10
    response_timeout_seconds = 5
    healthy_threshold        = 5
    unhealthy_threshold      = 3
  }

  droplet_tag = var.tag_elb_master_name
}
