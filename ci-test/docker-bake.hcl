group "default" {
  targets = [
    "ci-test-13",
    "ci-test-13-otp29",
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

# Erlang/OTP 29, for cinc-server 16, which ships on OTP 29. ci-test:13 and
# :latest stay on OTP 26 until nothing builds against it.
target "ci-test-13-otp29" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
  ]
  tags = [
    "cincproject/ci-test:13-otp29",
  ]
  args = {
    VERSION = "trixie"
    ERLANG_VERSION = "29.1.1"
  }
}
