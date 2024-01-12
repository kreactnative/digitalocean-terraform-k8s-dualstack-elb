
resource "null_resource" "init-worker" {
  depends_on = [null_resource.join-first-master]
  count      = length(digitalocean_droplet.worker)
  provisioner "file" {
    source      = "join-worker.sh"
    destination = "/tmp/join-worker.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.worker[count.index].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "templates/worker.tmpl"
    destination = "/tmp/worker.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = digitalocean_droplet.worker[count.index].ipv4_address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo /bin/sh -c 'echo \"${digitalocean_droplet.worker[count.index].ipv6_address} ${digitalocean_droplet.worker[count.index].name}\" >> /etc/hosts'",
      "export KUBEADM_JOIN_CERTKEY=\"$(cat  /tmp/join-worker.sh | grep \"$10\" | awk ' { printf $10 } ')\"",
      "export KUBEADM_JOIN_CACERT=\"$(cat  /tmp/join-worker.sh | grep \"$7\" | awk ' { printf $7 } ')\"",
      "export KUBEADM_JOIN_TOKEN=\"$(cat  /tmp/join-worker.sh | grep \"$5\" | awk ' { printf $5 } ')\"",
      "echo $KUBEADM_JOIN_CERTKEY",
      "echo $KUBEADM_JOIN_CACERT",
      "echo $KUBEADM_JOIN_TOKEN",
      "sed -i \"s/ipv4addr/\"${digitalocean_droplet.worker[count.index].ipv4_address}\"/g\" /tmp/worker.yaml",
      "sed -i \"s/kubeadm_join_certkey/$KUBEADM_JOIN_CERTKEY/g\" /tmp/worker.yaml",
      "sed -i \"s/kubeadm_join_token/$KUBEADM_JOIN_TOKEN/g\" /tmp/worker.yaml",
      "sed -i \"s/kubeadm_join_cacert/$KUBEADM_JOIN_CACERT/g\" /tmp/worker.yaml",
      "sed -i \"s/loadbalancer_ipv4/\"${digitalocean_droplet.control-plane[0].ipv4_address}\"/g\" /tmp/worker.yaml",
      "sed -i \"s/ipv6addr/\"${digitalocean_droplet.worker[count.index].ipv6_address}\"/g\" /tmp/worker.yaml",
      "sudo kubeadm join --config=/tmp/worker.yaml"
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
