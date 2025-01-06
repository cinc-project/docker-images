group "default" {
  targets = [
    "omnibus-rockylinux-8",
    "omnibus-rockylinux-9"
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
  args = {
    VERSION = "9"
  }
  tags = [
    "cincproject/omnibus-rockylinux:9",
    "cincproject/omnibus-rockylinux:latest",
  ]
}
