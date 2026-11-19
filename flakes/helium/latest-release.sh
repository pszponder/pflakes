#!/usr/bin/env bash
set -euo pipefail

headers=(-H 'Accept: application/vnd.github+json')
if [[ -n ${GH_TOKEN:-} ]]; then
	headers+=(-H "Authorization: Bearer $GH_TOKEN")
fi

curl --fail --silent --show-error --retry 3 "${headers[@]}" \
	https://api.github.com/repos/imputnet/helium-linux/releases/latest |
	jq -e '
    def digest($version; $arch):
      [.assets[] | select(.name == "helium-bin_\($version)-1_\($arch).deb") | .digest]
      | if length == 1 and (.[0] | strings | test("^sha256:[a-f0-9]{64}$"))
        then .[0] | ltrimstr("sha256:")
        else error("Missing or invalid SHA-256 digest for \($arch)")
        end;

    (.tag_name | strings | select(test("^v?[0-9]+(\\.[0-9]+){3}$"))) as $tag
    | ($tag | ltrimstr("v")) as $version
    | {
        tag: $tag,
        version: $version,
        sha256: {amd64: digest($version; "amd64"), arm64: digest($version; "arm64")}
      }
  '
