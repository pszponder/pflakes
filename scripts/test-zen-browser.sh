#!/usr/bin/env bash
set -euo pipefail

echo "Testing the standalone and collection Zen launchers..."
nix run --no-update-lock-file path:./flakes/zen-browser -- --version
nix run --no-update-lock-file path:.#zen-browser -- --version
echo "PASS: Both Zen launchers printed their version."

if [[ ${1:-} == --launch ]]; then
	profile=$(mktemp -d -t zen-test.XXXXXXXX)
	trap 'rm -rf -- "$profile"' EXIT
	echo "Opening about:support with test profile $profile. Close Zen to finish."
	nix run --no-update-lock-file path:.#zen-browser -- --no-remote --profile "$profile" about:support
	echo "PASS: Zen exited successfully."
fi
