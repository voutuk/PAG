#!/bin/bash

# Node exporter - https://github.com/prometheus/node_exporter/releases
VERSION=1.7.0
RELEASE=node_exporter-${VERSION}.linux-amd64
# Please Edit SHA256

if [[ $(openssl dgst -sha256 "${RELEASE}.tar.gz" | awk '{print $2}') != "a550cd5c05f760b7934a2d0afad66d2e92e681482f5f57a917465b1fba3b02a6" ]]; then
  echo -e "\e[30m\e[41m ✘ SHA mismatch! File is corrupted. \e[0m"
  exit 1
fi
