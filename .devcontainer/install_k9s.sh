#!/bin/bash

# Fetch the latest release tag from GitHub API
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/derailed/k9s/releases/latest" | grep "tag_name" | cut -d '"' -f 4)

# Download and extract the binary
curl -sL "https://github.com/derailed/k9s/releases/download/$LATEST_RELEASE/k9s_Linux_amd64.tar.gz" | tar xz

# Move the binary to the destination directory
sudo mv "k9s" "/usr/local/bin/k9s"
sudo chmod +x "/usr/local/bin/k9s"

# Update environment variables
export TERM=xterm-256color
export KUBE_EDITOR=nano
