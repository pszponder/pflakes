#!/usr/bin/env bash
set -eu
trap 'echo "FAIL: Helium test failed (exit $?). See the error above." >&2' ERR
echo "Testing the local Helium package with --version..."
nix run path:./flakes/helium -- --version
echo "PASS: The local Helium launcher printed its version."
if [[ ${1:-} == --launch ]]; then
	profile=$(mktemp -d -t helium-test.XXXXXXXX)
	trap 'rm -rf -- "$profile"' EXIT
	nix run path:./flakes/helium#seed-test-profile -- "$profile"
	profile_dir="$profile/net.imput.helium"
	echo "Opening chrome://version with test profile $profile_dir. Close Helium to finish."
	nix run path:./flakes/helium#test-launch -- --user-data-dir="$profile_dir" chrome://version
	echo "PASS: Helium exited successfully."
fi
