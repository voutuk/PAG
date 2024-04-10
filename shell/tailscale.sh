#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

curl -fsSL https://tailscale.com/install.sh | sudo sh
sudo tailscale up --ssh --authkey 
