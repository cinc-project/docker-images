group "default" {
  targets = [
    "omnibus-opensuse",
  ]
}

target "omnibus-opensuse" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  tags = [
    "cincproject/omnibus-opensuse:15",
    "cincproject/omnibus-opensuse:15.6",
    "cincproject/omnibus-opensuse:latest",
  ]
  args = {
    VERSION = "15.6"
  }
}
