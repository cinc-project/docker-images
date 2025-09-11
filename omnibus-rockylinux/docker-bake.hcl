group "default" {
  targets = [
    "omnibus-rockylinux-8",
    "omnibus-rockylinux-9",
    "omnibus-rockylinux-10"
  ]
}

target "omnibus-rockylinux-8" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  tags = [
    "cincproject/omnibus-rockylinux:8",
  ]
  args = {
    VERSION = "8"
  }
}

target "omnibus-rockylinux-9" {
  inherits = ["omnibus-rockylinux-8"]
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/ppc64le",
  ]
  args = {
    VERSION = "9"
  }
  tags = [
    "cincproject/omnibus-rockylinux:9",
  ]
}

target "omnibus-rockylinux-10" {
  inherits = ["omnibus-rockylinux-8"]
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/ppc64le",
  ]
  args = {
    VERSION = "10"
  }
  tags = [
    "cincproject/omnibus-rockylinux:10",
    "cincproject/omnibus-rockylinux:latest",
  ]
}
