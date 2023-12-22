resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "rm -f talos_setup.sh cilium.sh talosconfig worker.yaml controlplane.yaml"
    working_dir = path.root
  }
}


resource "local_file" "talosctl_config" {
  depends_on = [
    digitalocean_droplet.control-plane,
    digitalocean_droplet.worker,
    digitalocean_loadbalancer.public
  ]
  content = templatefile("${path.root}/templates/talosctl.tmpl",
    {
      load_balancer      = digitalocean_loadbalancer.public.ip,
      node_map_masters   = tolist(digitalocean_droplet.control-plane.*.ipv4_address),
      node_map_workers   = tolist(digitalocean_droplet.worker.*.ipv4_address)
      primary_controller = digitalocean_droplet.control-plane[0].ipv4_address
    }
  )
  filename        = "talos_setup.sh"
  file_permission = "755"
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

resource "null_resource" "create_cluster" {
  depends_on = [local_file.talosctl_config, local_file.cilium_config]
  provisioner "local-exec" {
    command = "/bin/bash talos_setup.sh"
  }
}
