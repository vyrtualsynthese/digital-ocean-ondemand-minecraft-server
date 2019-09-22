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
    source      = "minecraft-server.tar.gz"
    destination = "minecraft-server.tar.gz"
  }
  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "docker-compose.yml"
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
      "tar -xvf minecraft-server.tar.gz",
      "cd minecraft-server",
      "docker-compose up -d"
      ]
  }
}
