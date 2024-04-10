#!/bin/bash

# Prometheus - https://github.com/prometheus/prometheus/releases
VERSION=2.51.1
RELEASE=prometheus-${VERSION}.linux-amd64
# Please Edit SHA256

handle_error() {
    echo -e "\e[30m\e[41m ✘ An error occurred during execution at line $BASH_LINENO. \e[0m"
    exit 1
}
trap 'handle_error' ERR

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
rm -rf ${RELEASE} ${RELEASE}.tar.gz
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
EOF
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

echo -e "\e[48;5;250m\e[30m ✎ Create service \e[0m"
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
[Install]
WantedBy=multi-user.target
EOF

echo -e "\e[48;5;183m\e[30m ✶ Starting Prometheus \e[0m"
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo -e "\e[48;5;22m\e[30m ✓ Prometheus v${VERSION} installed successfully \e[0m"
