resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "rm -f talos_setup.sh cilium.sh talosconfig worker.yaml controlplane.yaml metallb.yaml"
    working_dir = path.root
  }
}
resource "local_file" "cilium_config" {
  depends_on = [
    digitalocean_droplet.control-plane,
    digitalocean_droplet.worker,
    digitalocean_loadbalancer.public
  ]
  content = templatefile("${path.root}/templates/cilium.tmpl",
    {
      load_balancer = digitalocean_loadbalancer.public.ip,
    }
  )
  filename        = "cilium.sh"
  file_permission = "755"
}

resource "local_file" "metallb_config" {
  depends_on = [
    digitalocean_droplet.control-plane,
    digitalocean_droplet.worker,
    digitalocean_loadbalancer.public,
    resource.local_file.cilium_config
  ]
  content = templatefile("${path.root}/templates/metallb.tmpl",
    {
      node_map_masters   = tolist(digitalocean_droplet.control-plane.*.ipv4_address),
      node_map_workers   = tolist(digitalocean_droplet.worker.*.ipv4_address)
      primary_controller = digitalocean_droplet.control-plane[0].ipv4_address
    }
  )
  filename = "metallb.yaml"
}
