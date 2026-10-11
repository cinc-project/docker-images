group "default" {
  targets = [
    "omnibus-sles-15_7",
    "omnibus-sles-16_0"
  ]
}

target "omnibus-sles-15_7" {
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
    "cincproject/omnibus-sles:15.7",
    "cincproject/omnibus-sles:15",
  ]
  args = {
    VERSION = "15.7"
  }
}

target "omnibus-sles-16_0" {
  inherits = ["omnibus-sles-15_7"]
  tags = [
    "cincproject/omnibus-sles:16.0",
    "cincproject/omnibus-sles:16",
    "cincproject/omnibus-sles:latest",
  ]
  args = {
    VERSION = "16.0"
  }
}
