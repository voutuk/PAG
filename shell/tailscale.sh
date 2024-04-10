#!/bin/bash

curl -fsSL https://tailscale.com/install.sh | sudo sh
sudo tailscale up --ssh
