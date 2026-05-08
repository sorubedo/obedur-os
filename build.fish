#!/usr/bin/env fish
sudo bluebuild generate-iso --iso-name obedur-os.iso --secure-boot-url https://github.com/sorubedo/obedur-os/raw/refs/heads/main/MOK.der --enrollment-password obedur image ghcr.io/sorubedo/obedur-os:latest
