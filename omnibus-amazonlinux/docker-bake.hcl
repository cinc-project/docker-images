group "default" {
  targets = ["omnibus-amazonlinux"]
}

target "omnibus-amazonlinux" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64/v8"
  ]
  tags = [
    "cincproject/omnibus-amazonlinux:2023",
    "cincproject/omnibus-amazonlinux:latest",
  ]
  args = {
    VERSION = "2023"
  }
}
