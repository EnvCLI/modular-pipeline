#!/usr/bin/env sh
set -e

echo "Installing modular pipeline components"

echo "-> Getting EnvCLI ..."
sudo curl -L -s -o /usr/local/bin/envcli https://dl.bintray.com/envcli/golang/envcli/v0.5.1/envcli_linux_amd64
sudo chmod +x /usr/local/bin/envcli

echo "-> EnvCLI Configuration"
sudo mkdir -p /etc/envcli
sudo curl -L -s -o /etc/envcli/.envcli.yml https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/.envcli.yml
sudo envcli config set global-configuration-path /etc/envcli

echo "-> Getting NormalizeCI ..."
sudo curl -L -s -o /usr/local/bin/normalizeci https://www.philippheuer.me/linux_amd64
sudo chmod +x /usr/local/bin/normalizeci

echo "-> Getting CI Scripts ..."
sudo curl -L -s -o /usr/local/bin/ci-debug https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/ci-debug
sudo curl -L -s -o /usr/local/bin/go-test https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/go-test
sudo curl -L -s -o /usr/local/bin/go-build https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/go-build
sudo curl -L -s -o /usr/local/bin/bintray-publish https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/bintray-publish

echo "-> Executable permissions"
sudo chmod +x /usr/local/bin/*

if test -f ".envcli.yml"; then
    echo "-> Installing EnvCLI Aliases"
    sudo envcli install-aliases
fi
