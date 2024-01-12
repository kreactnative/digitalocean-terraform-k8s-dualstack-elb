resource "null_resource" "control-plane-setup" {
  depends_on = [digitalocean_droplet.control-plane]
  count      = length(digitalocean_droplet.control-plane)
  provisioner "file" {
    source      = "scripts/setup-k8s.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[count.index].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh",
      "sudo sh -c  \"echo '${digitalocean_droplet.control-plane[count.index].ipv4_address} ${digitalocean_droplet.control-plane[count.index].name}' > /etc/hosts\"",
      "sudo sh -c  \"echo '${digitalocean_droplet.control-plane[count.index].ipv6_address} ${digitalocean_droplet.control-plane[count.index].name}' > /etc/hosts\""
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.control-plane[count.index].ipv4_address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
resource "null_resource" "worker-setup" {
  depends_on = [digitalocean_droplet.worker]
  count      = length(digitalocean_droplet.worker)
  provisioner "file" {
    source      = "scripts/setup-k8s.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.worker[count.index].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh",
      "sudo sh -c  \"echo '${digitalocean_droplet.worker[count.index].ipv4_address} ${digitalocean_droplet.worker[count.index].name}' > /etc/hosts\"",
      "sudo sh -c  \"echo '${digitalocean_droplet.worker[count.index].ipv6_address} ${digitalocean_droplet.worker[count.index].name}' > /etc/hosts\""
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.worker[count.index].ipv4_address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
