resource "digitalocean_droplet" "mc-server" {
  image = "docker-18-04"
  name = "mc-server"
  region = "fra1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  connection {
    user = "root"
    type = "ssh"
    private_key = "${file(var.pvt_key)}"
    timeout = "2m"
  }
}
