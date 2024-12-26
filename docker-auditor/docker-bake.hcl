group "default" {
  targets = ["docker-auditor"]
}

target "docker-auditor" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/ppc64le",
    "linux/s390x"
  ]
  tags = [
    "cincproject/docker-auditor:latest",
  ]
  output = ["type=registry"]
}
