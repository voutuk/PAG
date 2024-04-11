#!/bin/bash
# Github: https://github.com/voutuk/PAG
# SPDX-License-Identifier: BSD Zero Clause License
#
# This script installs Alermanager on the server.
# Before using, edit VERSION(9), RELEASE(10), SHA256(22), and alertmanager.yml(36), alertmanager local ip(52).

# Alermanager - https://github.com/prometheus/alertmanager/releases
VERSION=0.27.0
RELEASE=alertmanager-${VERSION}.linux-amd64
# Please Edit SHA256

set -o errexit
set -o nounset
set -o pipefail

echo -e "\e[30;44m ❍ Downloading Alermanager v${VERSION} \e[0m"
cd /tmp
curl -LO https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/${RELEASE}.tar.gz
#curl -LO https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
echo -e "\e[30;44m ❍ Checking SHA256 \e[0m"
if [[ $(openssl dgst -sha256 ${RELEASE}.tar.gz | awk '{print $2}') != "23c3f5a3c73de91dbaec419f3c492bef636deb02680808e5d842e6553aa16074" ]]; then # Edit SHA256
  echo -e "\e[30m\e[41m ✘ SHA mismatch! File is corrupted. \e[0m"
  exit 1
fi

echo -e "\e[30;44m ❍ Unpack delete chmod file, useradd \e[0m"
sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mkdir -p /etc/alertmanager/templates
sudo mkdir /var/lib/alertmanager
tar -xvf ${RELEASE}.tar.gz
sudo cp ${RELEASE}/alertmanager /usr/bin/
sudo cp ${RELEASE}/amtool /usr/bin/
sudo chown alertmanager:alertmanager /usr/bin/amtool
sudo chown alertmanager:alertmanager /usr/bin/alertmanager
sudo cp /vagrant/alertmanager.yml /etc/alertmanager/alertmanager.yml # Please Change this file and folder
chmod 600 /etc/alertmanager/alertmanager.yml
sudo chown -R alertmanager:alertmanager /etc/alertmanager
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager
rm -rf ${RELEASE} ${RELEASE}.tar.gz

echo -e "\e[48;5;250m\e[30m ✎ Create service \e[0m"
sudo sh -c 'cat > /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=AlertManager
Wants=network-online.target
After=network-online.target
[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/bin/alertmanager --config.file /etc/alertmanager/alertmanager.yml --storage.path /var/lib/alertmanager/ --web.external-url http://alertmg.tailade5f.ts.net:9093
[Install]
WantedBy=multi-user.target
EOF' # Please Edit alertmanager local ip

echo -e "\e[48;5;183m\e[30m ✶ Starting Alermanager \e[0m"
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager

echo -e "\e[48;5;22m\e[30m ✓ Alermanager v${VERSION} installed successfully \e[0m"
