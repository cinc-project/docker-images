group "default" {
  targets = [
    "omnibus-opensuse-15_6",
    "omnibus-opensuse-16_0"
  ]
}

target "omnibus-opensuse-15_6" {
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
    "cincproject/omnibus-opensuse:15.6",
    "cincproject/omnibus-opensuse:15",
  ]
  args = {
    VERSION = "15.6"
  }
}

target "omnibus-opensuse-16_0" {
  inherits = ["omnibus-opensuse-15_6"]
  tags = [
    "cincproject/omnibus-opensuse:16.0",
    "cincproject/omnibus-opensuse:16",
    "cincproject/omnibus-opensuse:latest",
  ]
  args = {
    VERSION = "16.0"
  }
}
