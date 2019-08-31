#!/usr/bin/env sh
set -e

echo "Installing modular pipeline components"

echo "-> Getting EnvCLI ..."
curl -L -s -o /usr/local/bin/envcli https://dl.bintray.com/envcli/golang/envcli/v0.6.0/envcli_linux_amd64
chmod +x /usr/local/bin/envcli

echo "-> EnvCLI Configuration"
mkdir -p /etc/envcli
envcli config set global-configuration-path /etc/envcli
curl -L -s -o /etc/envcli/.envcli.yml https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/.envcli.yml
chmod 644 /etc/envcli/.envcli.yml
cp /etc/envcli/.envcli.yml /usr/local/bin/.envcli.yml # temporary workaround, since config set didn't seem to have any effect

echo "-> Getting NormalizeCI ..."
curl -L -s -o /usr/local/bin/normalizeci https://dl.bintray.com/envcli/golang/normalize-ci/v0.0.1/linux_amd64
chmod +x /usr/local/bin/normalizeci

echo "-> Getting CI Scripts ..."
curl -L -s -o /usr/local/bin/common-pipeline-scripts https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/common-pipeline-scripts
curl -L -s -o /usr/local/bin/ci-debug https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/ci-debug
curl -L -s -o /usr/local/bin/go-test https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/go-test
curl -L -s -o /usr/local/bin/go-build https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/go-build
curl -L -s -o /usr/local/bin/bintray-publish https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/bintray-publish
curl -L -s -o /usr/local/bin/optimize-upx https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/optimize-upx

echo "-> Installing EnvCLI Aliases"
envcli install-aliases

echo "-> Executable permissions"
chmod +x /usr/local/bin/*
