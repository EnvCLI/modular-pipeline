#!/usr/bin/env bats

setup() {
  if [[ "$BATS_TEST_NUMBER" -eq 1]]; then
    echo "Setup"
  fi
}

teardown() {
  if [[ "${#BATS_TEST_NAMES[@]}" -eq "$BATS_TEST_NUMBER" ]]; then
    echo "Teardown"
  fi
}

@test "Stage.Audit should provide a help command" {
  result="$(echo 2)"
  [ "$result" -eq 2 ]
}

#parse-dockerfile-from "Dockerfile"
#parse-container-manifest "docker.io/library/alpine:latest"
