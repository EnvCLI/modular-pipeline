#!/usr/bin/env bash
set -euo pipefail

# Public: Build a go binary
#
# Builds the go project for the provided os / arch.
#
# $1 - The build os for cross-compilation (see spec for all valid values)
# $2 - The build arch (see spec for all valid values)
#
# Examples
#
#   _build_go "linux" "amd64"
#   _build_go "linux" "arm64v8"
#   _build_go "windows" "amd64"
#
# Returns the exit code of the last command executed or 0 otherwise.
_build_go() {
  ARTIFACT=$1_$2
  ARTIFACT_OS=$1
  ARTIFACT_ARCH=$2
  GOARM=

  # arm architectures -> https://github.com/golang/go/wiki/GoArm#supported-architectures
  if [[ $ARTIFACT_ARCH == 'arm32v6' ]]; then
    ARTIFACT_ARCH=arm
    GOARM=6
  elif [[ $ARTIFACT_ARCH == 'arm32v7' ]]; then
    ARTIFACT_ARCH=arm
    GOARM=7
  elif [[ $ARTIFACT_ARCH == 'arm64v8' ]]; then
    ARTIFACT_ARCH=arm64
  fi

  @mpi.log_message "INFO" "Generating golang artifact $ARTIFACT [$NCI_COMMIT_REF_RELEASE] ..."
  # shellcheck disable=SC2086
  @mpi.container_command \
    --env GOOS=$ARTIFACT_OS \
    --env GOARCH=$ARTIFACT_ARCH \
    --env GOARM=$GOARM \
    --env CGO_ENABLED=0 \
    --env GOPROXY=${GOPROXY:-https://goproxy.io} \
    go build -o "$ARTIFACT_DIR/$ARTIFACT" -ldflags "-w -X main.version=$NCI_COMMIT_REF_RELEASE -X main.commit=$NCI_COMMIT_SHA -X main.date=`date -u +%Y%m%d.%H%M%S` ${GO_BUILD_LDFLAGS:-}" "${GO_BUILD_SRCDIR:-./src}"
  @mpi.log_message "INFO" "Successfully generated artifact $ARTIFACT_DIR/$ARTIFACT [$(ls -lh $ARTIFACT_DIR/$ARTIFACT | cut -d " " -f5)]"
}

# Main Function
#
# Environment:
#  ARTIFACT_DIR: The target directory for generated artifact files, defaults to /dist
#  ARTIFACT_BUILD_ARCHS: The type of binaries that should be build, supported are [linux_386,linux_amd64,linux_armv7,linux_armv8,windows_386,windows_amd64,darwin_386,darwin_amd64]
#
# Returns the exit code of the last command executed or 0 otherwise.
function main()
{
  # code generation
  @mpi.log_message "INFO" "Running golang code generation"
  @mpi.container_command \
    --env GOPROXY=${GOPROXY:-https://goproxy.io} \
    go generate ./...

  # if godep usage is detected
  if [[ -f "Gopkg.lock" ]]; then
    @mpi.log_message "INFO" "downloading dependencies"
    @mpi.container_command dep ensure -v

    @mpi.log_message "INFO" "installed packages"
    @mpi.container_command dep status
  fi

  # build artifacts
  @mpi.log_message "INFO" "Running golang artifact generation"
  # linux_386
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'linux_386'; then
    _build_go linux 386 &
  fi
  # linux_amd64
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'linux_amd64'; then
    _build_go linux amd64 &
  fi
  # linux_arm32v6
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'linux_arm32v6'; then
    _build_go linux arm32v6 &
  fi
  # linux_arm32v7
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'linux_arm32v7'; then
    _build_go linux arm32v7 &
  fi
  # linux_arm64v8
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'linux_arm64v8'; then
    _build_go linux arm64v8 &
  fi
  # windows_386
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'windows_386'; then
    _build_go windows 386 &
  fi
  # windows_amd64
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'windows_amd64'; then
    _build_go windows amd64 &
  fi
  # darwin_amd64
  if echo "$ARTIFACT_BUILD_ARCHS" | grep -q 'darwin_amd64'; then
    _build_go darwin amd64 &
  fi

  # wait for all builds to finish
  wait
}

# entrypoint
main "$@"
