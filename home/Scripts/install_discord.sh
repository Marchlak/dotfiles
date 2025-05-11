#!/usr/bin/env bash
set -e
tmpdir=$(mktemp -d)
cd "$tmpdir"
wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
sudo apt update
sudo apt install -y ./discord.deb
cd -
rm -rf "$tmpdir"
