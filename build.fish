#!/usr/bin/env fish
set -gx MOK_PRIVATE_KEY (cat MOK.priv | string collect)
sudo --preserve-env=MOK_PRIVATE_KEY bluebuild generate-iso --iso-name obedur-os.iso recipe recipes/obedur-os.yml
