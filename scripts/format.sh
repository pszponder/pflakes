#!/usr/bin/env bash
set -euo pipefail

nixfmt_args=()
oxfmt_args=()
shfmt_args=(-w)
if [[ ${1:-} == --check ]]; then
	nixfmt_args=(--check)
	oxfmt_args=(--check)
	shfmt_args=(-d)
fi

# Include tracked and untracked files, respecting .gitignore.
git ls-files --cached --others --exclude-standard -z -- '*.nix' | xargs -0 -r nixfmt "${nixfmt_args[@]}"
oxfmt "${oxfmt_args[@]}"
git ls-files --cached --others --exclude-standard -z -- '*.sh' '*.bash' | xargs -0 -r shfmt -ln bash -s "${shfmt_args[@]}"
