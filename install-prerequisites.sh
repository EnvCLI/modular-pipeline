#! /usr/bin/env sh

###
# This script installs system prerequisites needed to work with the modular pipeline.
###

set -e
echo "Installing modular pipeline prerequisites ..."

SCRIPT_DIR=$(dirname "$0")

# prerequisites
if grep -q "alpine" "/etc/os-release"; then
  echo "Installing alpine packages ..."
  apk add --no-cache curl bash gettext git grep coreutils jq
elif grep -q "debian" "/etc/os-release" | grep -q "ubuntu" "/etc/os-release"; then
  apt-get install -y curl bash gettext git grep coreutils jq
fi

# envcli
if ! [ -x "$(command -v envcli)" ]; then
  curl -L -s -o /usr/local/bin/envcli https://dl.bintray.com/envcli/golang/envcli/v0.6.4/linux_amd64
  chmod +x /usr/local/bin/envcli
fi
