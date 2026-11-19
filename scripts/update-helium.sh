#!/usr/bin/env bash
set -euo pipefail

flake=flakes/helium
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

echo "Checking the latest Helium Linux release..."
bash "$flake/latest-release.sh" >"$scratch/release.json"
version=$(jq -r .version "$scratch/release.json")
if cmp -s "$scratch/release.json" "$flake/release.json"; then
	echo "Helium $version is up to date."
	exit 0
fi

# Test the candidate in isolation so a failed build leaves the working pin intact.
cp -R "$flake" "$scratch/helium"
cp "$scratch/release.json" "$scratch/helium/release.json"
echo "Building and smoke-testing Helium $version..."
nix run "path:$scratch/helium" -- --version
install -m 644 "$scratch/release.json" "$flake/release.json"
echo "Updated $flake/release.json to $version. Review and commit the change."
