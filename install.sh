#!/usr/bin/env bash
set -e
echo "Installing modular pipeline components"

# configuration
LOCAL_PATH=${BASH_SOURCE%/*}
INSTALL_FROM=${INSTALL_FROM:-remote}
INSTALL_MODE=${INSTALL_MODE:-system} # system or project (prject creates a .ci/bin dir and imports it into PATH)
CONFIG_DIR=${CONFIG_DIR:-/etc/envcli}
TARGET_DIR=${TARGET_DIR:-/usr/local/bin}

# detect os and arch
case "$(uname -s)" in
    Linux*)     OS=linux;;
    Darwin*)    OS=darwin;;
    CYGWIN*)    OS=windows;;
    MINGW*)     OS=windows;;
    *)          OS="UNKNOWN:$(uname -s)"
esac
case "$(uname -m)" in
    x86_64*)    ARCH=amd64;;
    i386*)      ARCH=386;;
    *)          ARCH="UNKNOWN:$(uname -m)"
esac

# support for user-mode setup
if echo "$INSTALL_MODE" | grep -q 'project'; then
    TARGET_DIR="$(pwd)/.ci/bin"
    mkdir -p "$(pwd)/.ci/bin"
    PATH=$PATH:$(pwd)/.ci/bin
    export PATH
fi

# preq: envcli
echo "-> getting envcli ..."
if ! test -f "$TARGET_DIR/envcli"; then
    echo "--> installing envcli into $TARGET_DIR"
    curl -L -s -o "$TARGET_DIR/envcli" "https://dl.bintray.com/envcli/golang/envcli/v0.6.0/envcli_${OS}_${ARCH}"
    chmod +x "$TARGET_DIR/envcli"
fi
echo "-> configuring envcli"
mkdir -p "$CONFIG_DIR"
envcli config set global-configuration-path "$CONFIG_DIR"
chmod 644 "$TARGET_DIR/.envclirc"
if echo "$INSTALL_FROM" | grep -q 'remote'; then
    curl -L -s -o "$CONFIG_DIR/.envcli.yml" "https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/.envcli.yml"
elif echo "$INSTALL_FROM" | grep -q 'local'; then
    cp "$LOCAL_PATH/.envcli.yml" "$CONFIG_DIR/.envcli.yml"
fi
chmod 644 "$CONFIG_DIR/.envcli.yml"

# req: normalizeci
echo "-> getting normalize-ci ..."
if ! test -f "$TARGET_DIR/normalizeci"; then
    curl -L -s -o "$TARGET_DIR/normalizeci" "https://dl.bintray.com/envcli/golang/normalize-ci/v0.0.2/${OS}_${ARCH}"
    chmod +x "$TARGET_DIR/normalizeci"
fi

# pipeline
echo "-> getting pipeline scripts ..."
# - actions
ACTION_LIST=("action-common" "action-common-deploy" "action-common-go" "action-common-java" "action-common-kubernetes" "action-ci-debug" "action-go-test" "action-go-build" "action-java-test" "action-java-build" "action-optimize-upx" "action-package-dockerfile" "action-swarm-deploy")
for i in "${ACTION_LIST[@]}"; do
    echo "--> action: $i"
    if echo "$INSTALL_FROM" | grep -q 'remote'; then
        curl -L -s -o "$TARGET_DIR/$i" "https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/actions/$i"
    elif echo "$INSTALL_FROM" | grep -q 'local'; then
        cp "$LOCAL_PATH/actions/$i" "$TARGET_DIR/$i"
    fi
    chmod +x "$TARGET_DIR/$i"
done
# - stages
STAGE_LIST=("stage-prepare" "stage-build" "stage-test" "stage-package" "stage-audit" "stage-deploy" "stage-performance" "stage-cleanup")
for i in "${STAGE_LIST[@]}"; do
    echo "--> stage: $i"
    if echo "$INSTALL_FROM" | grep -q 'remote'; then
        curl -L -s -o "$TARGET_DIR/$i" "https://raw.githubusercontent.com/EnvCLI/modular-pipeline/master/stages/$i"
    elif echo "$INSTALL_FROM" | grep -q 'local'; then
        cp "$LOCAL_PATH/stages/$i" "$TARGET_DIR/$i"
    fi
    chmod +x "$TARGET_DIR/$i"
done
