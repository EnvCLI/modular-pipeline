#!/usr/bin/env bash
set -euo pipefail

# Public: Authenticate against a container registry
#
# This will sign in to a remote container registry.
#
# $1 - The registry hostname
# $2 - The registry username
# $3 - The registry password
#
# Examples
#
#   @mpi.container.registry_login "hostname" "user" "pass"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.registry_login() {
  declare registryHost="$1" registryUsername="$2" registryPassword="$3"
  @mpi.log_message "INFO" "trying to login to container registry [$registryHost] as [$registryUsername] ..."

  if [[ -n "$registryUsername" ]] && [[ -n "$registryPassword" ]] && [[ -n "$registryHost" ]]; then
    @mpi.run_command docker login -u "$registryUsername" -p "$registryPassword" "$registryHost"
  else
    @mpi.log_message "ERROR" "Failed to login to container registry! No credentials provided!"
    exit 1
  fi
}

# Public: Parse the from statement of the dockerfile
#
# Takes the filepath to a dockerfile as argument and will search for
# the FROM line. It will then check if it contains the BASE_IMAGE as
# default var and extract the default value.
# This will export the following 2 variables:
# - CONTAINER_BASE_IMAGE_REPOSITORY
# - CONTAINER_BASE_IMAGE_TAG
#
# $1 - The dockerfile that should be analysed (ie. Dockerfile)
#
# Examples
#
#   container_parse_dockerfile_baseimage "Dockerfile"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.parse_dockerfile_baseimage() {
  declare dockerfile="$1"

  IFS=':' read -r -a baseImageArray <<< $(cat "$dockerfile" | grep "FROM \${BASE_IMAGE:-" | cut -c 20- | tr -d '}')
  export CONTAINER_BASE_IMAGE_REPOSITORY=${baseImageArray[0]}
  export CONTAINER_BASE_IMAGE_TAG=${baseImageArray[1]}
}

# Public: Parse the manifest of a container image
#
# Takes a container image as argument and evaluates the manifest. Will then export
# a variable for each entry as `MANIFEST_DIGEST_linux_amd64` which contains the
# digest of the image for that specific os/architecture.
#
# $1 - The container image that should be analysed (ie. docker.io/alpine:latest)
#
# Examples
#
#   container_parse_manifest "docker.io/alpine:latest"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.parse_manifest() {
  declare containerImage="$1"

  local temporaryManifestFile="${TMP_DIR}/manifest.json"
  local temporaryManifestResultFile=$(mktemp)
  @mpi.log_message "DEBUG" "extracting manifest json of the base image ..."
  @mpi.run_command docker manifest inspect "$containerImage" > "$temporaryManifestFile"
  @mpi.container_command jq '.manifests[] | [.platform.os,.platform.architecture,.platform.variant,.digest] | @csv' "$temporaryManifestFile" | tr -d '\\"' > "$temporaryManifestResultFile"
  readarray -t manifestArchs < $temporaryManifestResultFile

  # for each manifest entry
  for KEY in "${manifestArchs[@]}"; do
    @mpi.log_message "DEBUG" "processing base image manifest line: [$KEY]"

    IFS=', ' read -r -a row <<< "$KEY"
    local manifestOS="${row[0]}"
    local manifestArch="${row[1]}"
    local manifestVariant="${row[2]}"
    local manifestDigest="${row[3]}"

    # overwrite values to be conform the pipeline spec
    if echo "${manifestArch}_${manifestVariant}" | grep -q 'arm_v6'; then
      manifestArch=arm32v6
    elif echo "${manifestArch}_${manifestVariant}" | grep -q 'arm_v7'; then
      manifestArch=arm32v7
    elif echo "${manifestArch}_${manifestVariant}" | grep -q 'arm64_v8'; then
      manifestArch=arm64v8
    fi
    @mpi.log_message "DEBUG" "setting property [${manifestOS}_${manifestArch}] to [${manifestDigest}]"

    # store for later use when overwriting BASE_IMAGE via build arg
    export "MANIFEST_DIGEST_${manifestOS}_${manifestArch}=$manifestDigest"
  done
}

# Public: Create a manifest to point at images with different archs
#
# Takes a primary manifest
#
# $1 - The container image that should be created (the manifest)
# $2 - The archs that the manifest should contain
#
# Examples
#
#   create-container-manifest "docker.io/alpine:latest" "linux_amd64,linux_arm64v8"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.create_manifest() {
  declare manifestName="$1" containerBuildArchs="$2"
  @mpi.log_message "DEBUG" "generating manifest [${manifestName}] pointing at [${containerBuildArchs}]"

  # args with all images contained in the manifest
  declare -a manifestArgs

  # build
  IFS=',' read -r -a artifactBuildArchArray <<< $(echo "$containerBuildArchs")
  for VALUE in "${artifactBuildArchArray[@]}"; do
    IFS='_' read -r -a row <<< "$VALUE"
    local buildOS="${row[0]}"
    local buildArch="${row[1]}"
    local variant="${buildOS}_${buildArch}"
    local imageName="${manifestName}_${variant}"

    @mpi.log_message "DEBUG" "adding variant ${imageName} to manifestArgs for manifest creation"
    manifestArgs=( "${manifestArgs[@]}" "$imageName" )
  done

  # create manifest
  @mpi.run_command docker manifest create --amend "${manifestName}" "${manifestArgs[@]}"
  @mpi.log_message "INFO" "created manifest ${imageName} with variants [${manifestArgs[@]}]"

  # manifest annotations
  IFS=',' read -r -a artifactBuildArchArray <<< $(echo "$containerBuildArchs")
  for VALUE in "${artifactBuildArchArray[@]}"; do
    IFS='_' read -r -a row <<< "$VALUE"
    local buildOS="${row[0]}"
    local buildArch="${row[1]}"
    local variant="${buildOS}_${buildArch}"
    local imageName="${manifestName}_${variant}"

    @mpi.log_message "DEBUG" "setting image annotation for [${imageName}] with [${variant}]"
    if echo "$variant" | grep -q 'linux_amd64'; then
      @mpi.run_command docker manifest annotate "$manifestName" "$imageName" \
        --os linux \
        --arch amd64
    elif echo "$variant" | grep -q 'linux_arm64v8'; then
      @mpi.run_command docker manifest annotate "$manifestName" "$imageName" \
        --os linux \
        --arch arm64 \
        --variant v8
    fi
  done

  # docker manifest push -p ownyourbits/example
}

# Public: Build a container image
#
# This will build a container image for a specified target os/arch
#
# $1 - The container image repo
# $2 - The container image tag
# $3 - The base image repo
# $4 - The base image tag
# $5 - The target os
# $6 - The target arch
#
# Examples
#
#   container_build "example" "latest" "docker.io/alpine" "latest" "linux" "amd64"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.build() {
  declare imageRepo="$1" imageTag="$2" baseImageRepo="$3" baseImageTag="$4" buildOS="$5" buildArch="$6"

  # parse the manifest of the base image, to check what is supported
  @mpi.log_message "INFO" "parsing manifest of the base image [$baseImageRepo:$baseImageTag]"
  @mpi.container.parse_manifest "$baseImageRepo:$baseImageTag"
  local digestVarName="MANIFEST_DIGEST_${buildOS}_${buildArch}"
  local overwriteWithTag=${!digestVarName}

  # buildkit
  export DOCKER_BUILDKIT=1

  # build
  @mpi.log_message "INFO" "building image [$imageRepo:$imageTag] for target platform [${buildOS}_${buildArch}]"
  @mpi.log_message "DEBUG" "will overwrite base image with: [$baseImageRepo@$overwriteWithTag]"
  # - labels: https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys
  @mpi.run_command docker build \
    --no-cache \
    --build-arg "BASE_IMAGE=${baseImageRepo}@${overwriteWithTag}" \
    --build-arg "http_proxy=$HTTP_PROXY" \
    --build-arg "https_proxy=$HTTPS_PROXY" \
    --build-arg "proxy_host=$PROXY_HOST" \
    --build-arg "proxy_port=$PROXY_PORT" \
    --label "org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --label "org.opencontainers.image.version=$NCI_COMMIT_REF_RELEASE" \
    --label "org.opencontainers.image.revision=$NCI_COMMIT_SHA" \
    -f $DOCKERFILE \
    -t ${imageRepo}:${imageTag}_${buildOS}_${buildArch} \
    .
  @mpi.log_message "INFO" "image build success, tagged as [${imageRepo}:${imageTag}_${buildOS}_${buildArch}]"

  # detect image base
  @mpi.container.generate_os_package_list "${imageRepo}:${imageTag}_${buildOS}_${buildArch}"

  # save imageg
  mkdir -p "${TMP_DIR}/container-image"
  local artifactName="${imageTag}_${buildOS}_${buildArch}"
  @mpi.run_command docker save "${imageRepo}:${imageTag}_${buildOS}_${buildArch}" > ${TMP_DIR}/container-image/${artifactName}.tar
  @mpi.log_message "INFO" "stored image into ${TMP_DIR}/container-image/${artifactName}"
}

# Public: Push to container registry
#
# This will push the specified image to the remote registry.
#
# $1 - The container image
#
# Examples
#
#   container_registry_push "docker.io/alpine:latest"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.registry_push()
{
  declare containerImage="$1"

  @mpi.log_message "INFO" "pushing image [${containerImage}] to remote registry ..."
  @mpi.run_command docker push "${containerImage}"
}

# Public: Detect container base os
#
# Gets the os id of the base os, can be used to run os-specific action in a container.
# Will set CONTAINER_BASE_OS to one of the following values:
# - alpine
# - debian
# - ubuntu
# - fedora
# - centos
# - rhel
#
# $1 - The container image that should be created (the manifest)
#
# Examples
#
#   detect_container_base_os "docker.io/alpine:latest"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.detect_base_os() {
  declare containerImage="$1"

  local releaseId=$(docker run -it --rm --user root ${containerImage} cat /etc/os-release | grep -oP '(?<=^ID=).+' | tr -d '"' | tr -d '\r')
  @mpi.log_message "INFO" "image [${containerImage}] has base os [${releaseId}]"

  export CONTAINER_BASE_OS="${releaseId}"
}

# Public: Generate a list of system packages installed in a container image
#
# This will generate a list of installed system packages installed in a container image.
# Will create a file in TMP_DIR named container_os_packages.txt
#
# $1 - The container image
#
# Examples
#
#   generate_os_package_list "docker.io/alpine:latest"
#
# Returns the exit code of the last command executed or 0 otherwise.
@mpi.container.generate_os_package_list() {
  declare containerImage="$1"

  # sets CONTAINER_BASE_OS
  @mpi.container.detect_base_os "$containerImage"

  # run os specific commands
  if [ "${CONTAINER_BASE_OS}" == "alpine" ]; then
    @mpi.run_command docker run --rm --user root --entrypoint= "$containerImage" apk info --no-cache -v | grep -v '^fetch http' | sort > "${TMP_DIR}/container_os_packages.txt"
    @mpi.run_command docker run --rm --user root --entrypoint= "$containerImage" apk upgrade --latest | grep 'Upgrading ' | awk '{ print substr($0, index($0,$3)) }' | sort > "${TMP_DIR}/container_os_packages_available.txt"
  elif [ "${CONTAINER_BASE_OS}" == "debian" ] | [ "${CONTAINER_BASE_OS}" == "ubuntu" ]; then
    @mpi.run_command docker run --rm --user root --entrypoint= "$containerImage" dpkg-query -f '${Package};${Version} ${Status}\n' -W "*" | awk '$NF == "installed"{print $1}' | sort > "${TMP_DIR}/container_os_packages.txt"
    @mpi.run_command docker run --rm --user root --entrypoint= "$containerImage" sh -c 'apt-get -qq update && apt-get -s upgrade' | awk -F'[][() ]+' '/^Inst/{printf "%s;%s;%s\n", $2,$3,$4}' | sort > "${TMP_DIR}/container_os_packages_available.txt"
  elif [ "${CONTAINER_BASE_OS}" == "fedora" ] | [ "${CONTAINER_BASE_OS}" == "centos" ] | [ "${CONTAINER_BASE_OS}" == "rhel" ]; then
    @mpi.run_command docker run --rm --user root --entrypoint= "$containerImage" yum list installed -q | sed '1d' | awk '{ print $1 ";" $2 }' | sort > "${TMP_DIR}/container_os_packages.txt"
    @mpi.run_command docker run --rm --user root --entrypoint= "$containerImage" yum list updates -q | sed '1d' | awk '{ print $1 ";" $2 }' | sort > "${TMP_DIR}/container_os_packages_available.txt"
  else
    @mpi.log_message "INFO" "base os [${CONTAINER_BASE_OS}] not supported for automated package updates!"
  fi
}
