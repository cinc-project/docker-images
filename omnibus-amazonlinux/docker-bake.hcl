group "default" {
  targets = ["omnibus-amazonlinux"]
}

target "omnibus-amazonlinux" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  tags = [
    "cincproject/omnibus-amazonlinux:2023",
  ]
  args = {
    VERSION = "2023"
  }
}
