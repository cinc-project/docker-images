group "default" {
  targets = [
    "ci-test-13",
  ]
}

target "ci-test-13" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
  ]
  tags = [
    "cincproject/ci-test:13",
    "cincproject/ci-test:latest",
  ]
  args = {
    VERSION = "trixie"
  }
}
