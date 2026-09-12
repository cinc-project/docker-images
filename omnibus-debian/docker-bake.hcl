group "default" {
  targets = [
    "omnibus-debian-12",
    "omnibus-debian-13"
  ]
}

target "omnibus-debian-12" {
  context = "."
  contexts = {
    shared = "../shared/omnibus"
  }
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  tags = [
    "cincproject/omnibus-debian:12",
  ]
  args = {
    VERSION = "12"
  }
}

target "omnibus-debian-13" {
  inherits = ["omnibus-debian-12"]
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/riscv64"
  ]
  tags = [
    "cincproject/omnibus-debian:13",
    "cincproject/omnibus-debian:latest",
  ]
  args = {
    VERSION = "trixie"
  }
}
