#!/usr/bin/env bash
set -euo pipefail

flake=flakes/zen-browser
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

# Refresh and test both lock files in a disposable copy of the collection.
cp -R flake.nix flake.lock flakes "$scratch/"
echo "Checking the Zen Browser packaging pin..."
(
	cd "$scratch"
	nix flake update zen-packaging --flake "path:./$flake"
	nix flake update zen-browser --flake path:.
)
if cmp -s "$scratch/$flake/flake.lock" "$flake/flake.lock" && cmp -s "$scratch/flake.lock" flake.lock; then
	echo "Zen Browser is up to date."
	exit 0
fi

test_script=$PWD/scripts/test-zen-browser.sh
(cd "$scratch" && bash "$test_script")
install -m 644 "$scratch/$flake/flake.lock" "$flake/flake.lock"
install -m 644 "$scratch/flake.lock" flake.lock
echo "Updated the Zen Browser pins. Review and commit the changes."
