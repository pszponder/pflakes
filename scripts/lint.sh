#!/usr/bin/env bash
set -euo pipefail

statix check .
git ls-files --cached --others --exclude-standard -z -- '*.nix' | xargs -0 -r deadnix --fail
git ls-files --cached --others --exclude-standard -z -- '*.sh' '*.bash' | xargs -0 -r shellcheck --shell=bash
