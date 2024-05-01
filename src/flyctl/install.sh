#!/usr/bin/env bash

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

FLYCTL_VERSION=${VERSION:-"latest"}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt_get_update()
{
    echo "Running apt-get update..."
    apt-get update -y
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt_get_update
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

# Install dependencies
check_packages ca-certificates curl tar

# Use a temporary location for flyctl archive
export TMP_DIR="/tmp/tmp-flyctl-install"
mkdir -p ${TMP_DIR}
chmod 700 ${TMP_DIR}

# Install flyctl
echo "(*) Installing flyctl..."
os=$(uname -s)
arch=$(uname -m)
flyctl_uri=$(curl -s https://api.fly.io/app/flyctl_releases/$os/$arch/$FLYCTL_VERSION)
if [ ! "$flyctl_uri" ]; then
    echo "Error: Unable to find a flyctl release for $os/$arch/$FLYCTL_VERSION - see github.com/superfly/flyctl/releases for all versions" 2>&1
    exit 1
fi

FLYCTL_VERSION="$(echo $flyctl_uri | grep -oP "\\/download\\/v\\K.+?\\..+?\\..+?(?=\\/)")"

echo "FLYCTL_VERSION=${FLYCTL_VERSION}"

curl -sSL -o ${TMP_DIR}/flyctl.tar.gz "$flyctl_uri"
tar -xzf "${TMP_DIR}/flyctl.tar.gz" -C "${TMP_DIR}" flyctl
mv ${TMP_DIR}/flyctl /usr/local/bin/flyctl
chmod 0755 /usr/local/bin/flyctl
ln -sf /usr/local/bin/flyctl /usr/local/bin/fly

# Clean up
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/tmp-flyctl-install

echo "Done!"
