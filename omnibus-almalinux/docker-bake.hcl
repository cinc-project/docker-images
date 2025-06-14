group "default" {
  targets = [
    "omnibus-almalinux-8",
    "omnibus-almalinux-9",
    "omnibus-almalinux-10"
  ]
}

target "omnibus-almalinux-8" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/ppc64le",
    "linux/s390x"
  ]
  tags = [
    "cincproject/omnibus-almalinux:8",
  ]
  args = {
    VERSION = "8"
  }
}

target "omnibus-almalinux-9" {
  inherits = ["omnibus-almalinux-8"]
  args = {
    VERSION = "9"
  }
  tags = [
    "cincproject/omnibus-almalinux:9",
  ]
}

target "omnibus-almalinux-10" {
  inherits = ["omnibus-almalinux-8"]
  args = {
    VERSION = "10"
  }
  tags = [
    "cincproject/omnibus-almalinux:10",
    "cincproject/omnibus-almalinux:latest",
  ]
}
