#! /usr/bin/env bash
set -e
echo "Installing modular pipeline ..."
downloadUrl=${downloadUrl:-https://github.com/EnvCLI/modular-pipeline/archive/master.zip}

# preq: envcli
if ! [ -x "$(command -v envcli)" ]; then
  echo "ERROR: please install envcli on your host machine!"
  exit 1
fi

#echo "-> configuring envcli"
#mkdir -p "$CONFIG_DIR"
#envcli config set global-configuration-path "$CONFIG_DIR"
#chmod 644 "$TARGET_DIR/.envclirc"
#if ! test -f "$CONFIG_DIR/.envcli.yml"; then
#  if echo "$INSTALL_FROM" | grep -q 'remote'; then
#    curl -L -s -o "$CONFIG_DIR/.envcli.yml" "$DOWNLOAD_MIRROR/.envcli.yml"
#  elif echo "$INSTALL_FROM" | grep -q 'local'; then
#    cp "$LOCAL_PATH/.envcli.yml" "$CONFIG_DIR/.envcli.yml"
#  fi
#  chmod 644 "$CONFIG_DIR/.envcli.yml"
#fi

# arguments
MPI_ROOT="${0%/*}"
PATH_PREFIX="$1"

if [[ -z "$PATH_PREFIX" ]]; then
  printf '%s\n' \
    "usage: $0 <prefix>" \
    "  e.g. $0 /usr/local" >&2
  exit 1
fi

# download
if [[ -d "src" ]]; then
  echo "Local installation ..."
else
  if ! [ -x "$(command -v curl)" ]; then
    echo "ERROR: please install curl on your host machine!"
    exit 1
  fi
  if ! [ -x "$(command -v unzip)" ]; then
    echo "ERROR: please install unzip on your host machine!"
    exit 1
  fi

  echo "Downloading ..."
  tmpDir=$(mktemp --directory)
  curl -L -s -o "$tmpDir/pipeline.zip" "$downloadUrl"
  unzip -q $tmpDir/pipeline.zip -d $tmpDir
  MPI_ROOT=$(realpath $tmpDir/modular-pipeline*)
fi

# installation
install -d -m 755 "$PATH_PREFIX"/{bin,libexec/mpi/{common,pipeline,actions,stages,action-helper,cfg}}
install -m 755 "$MPI_ROOT/src/bin"/* "$PATH_PREFIX/bin"
install -m 755 "$MPI_ROOT/src/libexec/mpi"/*.bash "$PATH_PREFIX/libexec/mpi"
install -m 755 "$MPI_ROOT/src/libexec/mpi/common"/* "$PATH_PREFIX/libexec/mpi/common"
install -m 755 "$MPI_ROOT/src/libexec/mpi/pipeline"/* "$PATH_PREFIX/libexec/mpi/pipeline"
install -m 755 "$MPI_ROOT/src/libexec/mpi/actions"/* "$PATH_PREFIX/libexec/mpi/actions"
install -m 755 "$MPI_ROOT/src/libexec/mpi/stages"/* "$PATH_PREFIX/libexec/mpi/stages"
install -m 755 "$MPI_ROOT/src/libexec/mpi/action-helper"/* "$PATH_PREFIX/libexec/mpi/action-helper"
install -m 755 "$MPI_ROOT/.envcli.yml" "$PATH_PREFIX/libexec/mpi/cfg/.envcli.yml"

echo "Installed MPI to $PATH_PREFIX/bin/mpi"
