#!/bin/bash

# Grafana - https://grafana.com/grafana/download
VERSION=10.4.1
RELEASE=grafana-enterprise_${VERSION}_amd64.deb
# Please Edit SHA256

set -o errexit
set -o nounset
set -o pipefail

echo -e "\e[30;44m ❍ Install packages \e[0m"
sudo apt-get install -y adduser libfontconfig1 musl -y

echo -e "\e[30;44m ❍ Downloading Grafana v${VERSION} \e[0m"
wget https://dl.grafana.com/enterprise/release/${RELEASE}

echo -e "\e[30;44m ❍ Checking SHA256 \e[0m"
if [[ $(openssl dgst -sha256 ${RELEASE} | awk '{print $2}') != "8abef0718e77364d8d1b04a26192eed47f7d7e3af5956bcee11e1e57a226e949" ]]; then # Edit SHA256
  echo -e "\e[30m\e[41m ✘ SHA mismatch! File is corrupted. \e[0m"
  exit 1
fi
sudo dpkg -i ${RELEASE}

echo -e "\e[48;5;183m\e[30m ✶ Starting Grafana \e[0m"
sudo systemctl start grafana-server
echo -e "\e[48;5;22m\e[30m ✓ Grafana v${VERSION} installed successfully \e[0m"