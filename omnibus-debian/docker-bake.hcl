group "default" {
  targets = [
    "omnibus-debian-11",
    "omnibus-debian-12"
  ]
}

target "omnibus-debian-11" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  tags = [
    "cincproject/omnibus-debian:11",
  ]
  args = {
    VERSION = "11"
  }
}

target "omnibus-debian-12" {
  inherits = ["omnibus-debian-11"]
  args = {
    VERSION = "12"
  }
  tags = [
    "cincproject/omnibus-debian:12",
  ]
}
