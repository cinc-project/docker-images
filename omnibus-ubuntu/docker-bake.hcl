group "default" {
  targets = [
    "omnibus-ubuntu-20_04",
    "omnibus-ubuntu-22_04",
    "omnibus-ubuntu-24_04"
  ]
}

target "omnibus-ubuntu-20_04" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  tags = [
    "cincproject/omnibus-ubuntu:20.04",
  ]
  args = {
    VERSION = "20.04"
  }
}

target "omnibus-ubuntu-22_04" {
  inherits = ["omnibus-ubuntu-20_04"]
  args = {
    VERSION = "22.04"
  }
  tags = [
    "cincproject/omnibus-ubuntu:22.04",
  ]
}

target "omnibus-ubuntu-24_04" {
  inherits = ["omnibus-ubuntu-20_04"]
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/riscv64"
  ]
  args = {
    VERSION = "24.04"
  }
  tags = [
    "cincproject/omnibus-ubuntu:24.04",
    "cincproject/omnibus-ubuntu:latest",
  ]
}
