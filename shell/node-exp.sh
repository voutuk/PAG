#!/bin/bash
# Github: https://github.com/voutuk/PAG
# SPDX-License-Identifier: BSD Zero Clause License
#
# This script installs Alermanager on the server.
# Before using, edit VERSION(9), RELEASE(10), SHA256(22).

# Node exporter - https://github.com/prometheus/node_exporter/releases
VERSION=1.7.0
RELEASE=node_exporter-${VERSION}.linux-amd64
# Please Edit SHA256

set -o errexit
set -o nounset
set -o pipefail

echo -e "\e[30;44m ❍ Downloading Node Exporter v${VERSION} \e[0m"
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${RELEASE}.tar.gz
#curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz   openssl dgst -sha256 node_exporter-1.7.0.linux-amd64.tar.gz | awk '{print $2}'
echo -e "\e[30;44m ❍ Checking SHA256 \e[0m"
if [[ $(openssl dgst -sha256 ${RELEASE}.tar.gz | awk '{print $2}') != "a550cd5c05f760b7934a2d0afad66d2e92e681482f5f57a917465b1fba3b02a6" ]]; then # Edit SHA256
  echo -e "\e[30m\e[41m ✘ SHA mismatch! File is corrupted. \e[0m"
  exit 1
fi

echo -e "\e[30;44m ❍ Unpack delete chmod file, useradd \e[0m"
tar -xvf ${RELEASE}.tar.gz
sudo mv ${RELEASE}/node_exporter /usr/local/bin/
rm -rf ${RELEASE} ${RELEASE}.tar.gz
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo chmod 500 /usr/local/bin/node_exporter

echo -e "\e[48;5;250m\e[30m ✎ Create service \e[0m"
sudo sh -c 'cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=180
StartLimitBurst=5
[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind
[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[48;5;183m\e[30m ✶ Starting Node Exporter \e[0m"
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo -e "\e[48;5;22m\e[30m ✓ Node Exporter v${VERSION} installed successfully \e[0m"

