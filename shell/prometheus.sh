#!/bin/bash
# Github: https://github.com/voutuk/PAG
# SPDX-License-Identifier: BSD Zero Clause License
#
# This script installs Prometheus on the server.
# Before using, edit VERSION(10), RELEASE(11), SHA256(23), and prometheus.yml(42-57).

# Prometheus - https://github.com/prometheus/prometheus/releases
VERSION=2.51.1
RELEASE=prometheus-${VERSION}.linux-amd64
# Please Edit SHA256

set -o errexit
set -o nounset
set -o pipefail

echo -e "\e[30;44m ❍ Downloading Prometheus v${VERSION} \e[0m"
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v${VERSION}/${RELEASE}.tar.gz
#curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.1/prometheus-2.51.1.linux-amd64.tar.gz
echo -e "\e[30;44m ❍ Checking SHA256 \e[0m"
if [[ $(openssl dgst -sha256 ${RELEASE}.tar.gz | awk '{print $2}') != "1f933ea7515e3a6e60374ee0bfdb62bc4701c7b12c1dbafe1865c327c6e0e7d2" ]]; then # Edit SHA256
  echo -e "\e[30m\e[41m ✘ SHA mismatch! File is corrupted. \e[0m"
  exit 1
fi

echo -e "\e[30;44m ❍ Unpack delete chmod file, useradd \e[0m"
sudo useradd --no-create-home --shell /bin/false prometheus
tar -xvf ${RELEASE}.tar.gz
sudo cp ${RELEASE}/prometheus /usr/local/bin/ && sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo cp ${RELEASE}/promtool /usr/local/bin/ && sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo mkdir /var/lib/prometheus
sudo mkdir /etc/prometheus
sudo cp -r ${RELEASE}/consoles /etc/prometheus
sudo cp -r ${RELEASE}/console_libraries /etc/prometheus
# Add standart alerts rules
wget https://raw.githubusercontent.com/samber/awesome-prometheus-alerts/master/dist/rules/host-and-hardware/node-exporter.yml
sudo mv node-exporter.yml /etc/prometheus/alert.rules.yml
rm -rf ${RELEASE} ${RELEASE}.tar.gz node-exporter.yml
sudo bash -c "cat << EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
rule_files:
  - alert.rules.yml
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['alertmg.tailade5f.ts.net:9093']
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'nodes'
    static_configs:
      - targets: ['node1.tailade5f.ts.net:9100']
EOF" # Please Edit node ip and alertmanager ip
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

echo -e "\e[48;5;250m\e[30m ✎ Create service \e[0m"
sudo sh -c 'cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries
[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[48;5;183m\e[30m ✶ Starting Prometheus \e[0m"
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo -e "\e[48;5;22m\e[30m ✓ Prometheus v${VERSION} installed successfully \e[0m"
