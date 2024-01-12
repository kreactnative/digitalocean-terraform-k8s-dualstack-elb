resource "local_file" "helm_ciliun_config" {
  depends_on = [
    local_file.cluster_config, null_resource.control-plane-setup
  ]
  content = templatefile("${path.root}/templates/helm-cni-lb.tmpl",
    {
      loadbalancer_ip = digitalocean_droplet.control-plane[0].ipv4_address
    }
  )
  filename = "helm-cni-lb.sh"
}

resource "null_resource" "init-cni-ig" {
  depends_on = [null_resource.control-plane-setup, null_resource.worker-setup, local_file.helm_ciliun_config]
  provisioner "file" {
    source      = "k8s/istio-operator.yaml"
    destination = "/tmp/istio-operator.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/metrics-server.yaml"
    destination = "/tmp/metrics-server.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/prometheus-stack-values.yaml"
    destination = "/tmp/prometheus-stack-values.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "helm-cni-lb.sh"
    destination = "/tmp/helm-cni-lb.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "scripts/cni-istio.sh"
    destination = "/tmp/cni-istio.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sed -i \"s/ig_load_balancer_ip4/\"${digitalocean_droplet.control-plane[0].ipv4_address}\"/g\" /tmp/metallb-ip.yaml",
      "sed -i \"s/ig_load_balancer_ip6/\"${digitalocean_droplet.control-plane[0].ipv6_address}\"/g\" /tmp/metallb-ip.yaml",
      "sudo chmod +x /tmp/helm-cni-lb.sh",
      "sudo /tmp/helm-cni-lb.sh",
      "sudo chmod +x /tmp/cni-istio.sh",
      "sudo /tmp/cni-istio.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
