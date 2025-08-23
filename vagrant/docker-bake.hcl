group "default" {
  targets = [
    "vagrant",
  ]
}

target "vagrant" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64"
  ]
  tags = [
    "cincproject/vagrant:latest",
  ]
}
