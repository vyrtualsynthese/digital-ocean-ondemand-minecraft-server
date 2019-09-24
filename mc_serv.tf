resource "digitalocean_droplet" "mc-server" {
  image = "docker-18-04"
  name = "mc-server"
  region = "fra1"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [
    var.ssh_fingerprint
  ]
  provisioner "file" {
    source      = "uploadFolder/"
    destination = "."
  }
  connection {
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
    host = digitalocean_droplet.mc-server.ipv4_address
  }
  provisioner "remote-exec" {
    inline = [
      "wget https://github.com/Tiiffi/mcrcon/releases/download/v0.0.5/mcrcon-0.0.5-linux-x86-64.tar.gz",
      "tar -xvf mcrcon-0.0.5-linux-x86-64.tar.gz",
      "mv mcrcon /usr/local/bin",
      "tar -xvf minecraft-server.tar.gz",
      "cd minecraft-server",
      "docker-compose up -d"
      ]
  }
  provisioner "remote-exec" {
    when    = "destroy"
    inline = [
      "mcrcon -H localhost -p ${var.rcon_pwd} save-all",
      "sleep 30",
      "mcrcon -H localhost -p ${var.rcon_pwd} stop",
      "sleep 30",
      "docker-compose down",
      "tar -cvf minecraft-server.tar.gz minecraft-server",
    ]
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${digitalocean_droplet.mc-server.ipv4_address}:minecraft-server.tar.gz uploadFolder"
  }
}
