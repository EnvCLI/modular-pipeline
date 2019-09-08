#!/usr/bin/env bash
set -e
echo "Installing modular pipeline components"

# configuration
LOCAL_PATH=${BASH_SOURCE%/*}
INSTALL_FROM=${INSTALL_FROM:-remote}
INSTALL_MODE=${INSTALL_MODE:-system} # system or project (prject creates a .ci/bin dir and imports it into PATH)
CONFIG_DIR=${CONFIG_DIR:-/etc/envcli}
TARGET_DIR=${TARGET_DIR:-/usr/local/bin}

# support for user-mode setup
if echo "$INSTALL_MODE" | grep -q 'project'; then
    TARGET_DIR=$(pwd)/.ci/bin
    mkdir -p $(pwd)/.ci/bin
    export PATH=$PATH:$(pwd)/.ci/bin
fi

# preq: envcli
echo "-> Getting EnvCLI ..."
if ! test -f $TARGET_DIR/envcli; then
    curl -L -s -o $TARGET_DIR/envcli https://dl.bintray.com/envcli/golang/envcli/v0.6.0/envcli_linux_amd64
    chmod +x $TARGET_DIR/envcli
fi
echo "-> EnvCLI Configuration"
mkdir -p $CONFIG_DIR
envcli config set global-configuration-path $CONFIG_DIR
chmod 644 $TARGET_DIR/.envclirc
if echo "$INSTALL_FROM" | grep -q 'remote'; then
    curl -L -s -o $CONFIG_DIR/.envcli.yml https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/.envcli.yml
elif echo "$INSTALL_FROM" | grep -q 'local'; then
    cp $LOCAL_PATH/.envcli.yml $CONFIG_DIR/.envcli.yml
fi
chmod 644 $CONFIG_DIR/.envcli.yml

# req: normalizeci
echo "-> Getting NormalizeCI ..."
if ! test -f $TARGET_DIR/normalizeci; then
    curl -L -s -o $TARGET_DIR/normalizeci https://dl.bintray.com/envcli/golang/normalize-ci/v0.0.1/linux_amd64
    chmod +x $TARGET_DIR/normalizeci
fi

# pipeline
echo "-> Getting CI Scripts ..."
ACTION_LIST=("action-common" "ci-debug" "action-go-test" "action-go-build" "action-java-build" "action-optimize-upx" "action-package-dockerfile")
for i in "${ACTION_LIST[@]}"; do
    echo "--> Action: $i"
    if echo "$INSTALL_FROM" | grep -q 'remote'; then
        curl -L -s -o $TARGET_DIR/$i https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/$i
        chmod +x $TARGET_DIR/$i
    elif echo "$INSTALL_FROM" | grep -q 'local'; then
        cp $LOCAL_PATH/actions/$i $TARGET_DIR/$i
        chmod +x $TARGET_DIR/$i
    fi
done

# aliases
echo "-> Installing EnvCLI Aliases"
envcli install-aliases
