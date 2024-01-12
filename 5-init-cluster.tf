resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "mkdir -p output && rm -f cluster.yaml join-master.sh join-worker.sh helm-cni-lb.sh"
    working_dir = path.root
  }
}
resource "local_file" "cluster_config" {
  depends_on = [
    null_resource.control-plane-setup, null_resource.worker-setup, null_resource.cleanup
  ]
  content = templatefile("${path.root}/templates/cluster.tmpl",
    {
      loadbalancer_ip     = digitalocean_droplet.control-plane[0].ipv4_address,
      current_master_ip   = digitalocean_droplet.control-plane[0].ipv4_address,
      current_master_ipv6 = digitalocean_droplet.control-plane[0].ipv6_address
    }
  )
  filename = "cluster.yaml"
}

resource "null_resource" "join-first-master" {
  depends_on = [local_file.cluster_config, null_resource.control-plane-setup, null_resource.worker-setup]
  provisioner "file" {
    source      = "cluster.yaml"
    destination = "/tmp/cluster.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "scripts/kube-init.sh"
    destination = "/tmp/kube-init.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/kube-init.sh",
      "sudo /tmp/kube-init.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[0].ipv4_address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${digitalocean_droplet.control-plane[0].ipv4_address}:/tmp/config $HOME/.kube/do-almalinux-k8s-ha-config"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${digitalocean_droplet.control-plane[0].ipv4_address}:/tmp/join-master.sh join-master.sh"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${digitalocean_droplet.control-plane[0].ipv4_address}:/tmp/join-worker.sh join-worker.sh"
  }
}
