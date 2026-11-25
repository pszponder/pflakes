#!/usr/bin/env bash
set -euo pipefail

flake=flakes/zen-browser
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

echo "Checking the latest official Zen Browser release..."
bash "$flake/latest-release.sh" >"$scratch/release.json"
if cmp -s "$scratch/release.json" "$flake/release.json"; then
	echo "Zen Browser is up to date."
	exit 0
fi

# Test the official release in isolation before replacing the working pin.
cp -R flake.nix flake.lock flakes "$scratch/"
install -m 644 "$scratch/release.json" "$scratch/$flake/release.json"
test_script=$PWD/scripts/test-zen-browser.sh
(cd "$scratch" && bash "$test_script")
install -m 644 "$scratch/release.json" "$flake/release.json"
echo "Updated the official Zen Browser release pin. Review and commit the change."
