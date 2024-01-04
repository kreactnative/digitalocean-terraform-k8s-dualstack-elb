resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "rm -f cilium.sh metallb.yaml cluster.yaml"
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
      load_balancer_ip = digitalocean_loadbalancer.public.ip,
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
      node_map_ipv4_masters = tolist(digitalocean_droplet.control-plane.*.ipv4_address),
      node_map_ipv6_masters = tolist(digitalocean_droplet.control-plane.*.ipv6_address)
    }
  )
  filename = "metallb.yaml"
}

resource "local_file" "cluster_config" {
  depends_on = [
    module.etcd_domain,
    module.elb_domain,
    null_resource.control-plane-config
  ]
  content = templatefile("${path.root}/templates/cluster.tmpl",
    {
      loadbalancer_ip     = digitalocean_loadbalancer.public.ip,
      current_master_ip   = digitalocean_droplet.control-plane[0].ipv4_address,
      current_master_ipv6 = digitalocean_droplet.control-plane[0].ipv6_address
    }
  )
  filename = "cluster.yaml"
}
