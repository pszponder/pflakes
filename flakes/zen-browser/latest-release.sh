#!/usr/bin/env bash
set -euo pipefail

scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
headers=(-H 'Accept: application/vnd.github+json')
if [[ -n ${GH_TOKEN:-} ]]; then
	headers+=(-H "Authorization: Bearer $GH_TOKEN")
fi
curl --fail --silent --show-error --retry 3 "${headers[@]}" \
	https://api.github.com/repos/zen-browser/desktop/releases/latest >"$scratch/latest.json"
version=$(jq -er '.tag_name | select(test("^[0-9]+(\\.[0-9]+)+b$"))' "$scratch/latest.json")
for arch in x86_64 aarch64; do
	url="https://github.com/zen-browser/desktop/releases/download/$version/zen.linux-$arch.tar.xz"
	jq -e --arg url "$url" 'any(.assets[]; .browser_download_url == $url)' "$scratch/latest.json" >/dev/null
	nix store prefetch-file --json --unpack "$url" >"$scratch/$arch-prefetch.json"
	store_path=$(jq -er .storePath "$scratch/$arch-prefetch.json")
	firefox_version=$(sed -n 's/^Milestone=//p' "$store_path/platform.ini" | tr -d '\r')
	[[ $firefox_version =~ ^[0-9]+(\.[0-9]+)*$ ]]
	jq --arg version "$version" --arg url "$url" --arg firefoxVersion "$firefox_version" \
		'{version: $version, url: $url, sha256: .hash, firefoxVersion: $firefoxVersion}' \
		"$scratch/$arch-prefetch.json" >"$scratch/$arch.json"
done
jq -n --slurpfile x86 "$scratch/x86_64.json" --slurpfile arm "$scratch/aarch64.json" \
	'{"x86_64-linux": $x86[0], "aarch64-linux": $arm[0]}'
