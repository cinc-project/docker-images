group "default" {
  targets = [
    "omnibus-debian-11",
    "omnibus-debian-12",
    "omnibus-debian-13"
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

target "omnibus-debian-13" {
  inherits = ["omnibus-debian-11"]
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/riscv64"
  ]
  tags = [
    "cincproject/omnibus-debian:13",
  ]
  args = {
    VERSION = "trixie"
  }
}
