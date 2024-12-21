group "default" {
  targets = [
    "vagrant-virtualbox",
  ]
}

target "vagrant-virtualbox" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64"
  ]
  tags = [
    "cincproject/vagrant-virtualbox:latest",
  ]
}
