set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Include tracked and untracked files, respecting .gitignore.
nix_files := "'*.nix'"
bash_files := "'*.sh' '*.bash'"

# List available recipes
default:
    @just --list

# Format supported files
fmt:
    git ls-files --cached --others --exclude-standard -z -- {{ nix_files }} | xargs -0 -r nixfmt
    oxfmt
    git ls-files --cached --others --exclude-standard -z -- {{ bash_files }} | xargs -0 -r shfmt -ln bash -s -w

# Check formatting without changing files
fmt-check:
    git ls-files --cached --others --exclude-standard -z -- {{ nix_files }} | xargs -0 -r nixfmt --check
    oxfmt --check
    git ls-files --cached --others --exclude-standard -z -- {{ bash_files }} | xargs -0 -r shfmt -ln bash -s -d

# Lint Nix and Bash files
lint:
    statix check .
    git ls-files --cached --others --exclude-standard -z -- {{ nix_files }} | xargs -0 -r deadnix --fail
    git ls-files --cached --others --exclude-standard -z -- {{ bash_files }} | xargs -0 -r shellcheck --shell=bash

# Evaluate the development environment and run its formatting and lint checks
check:
    devenv test

# Run all validation checks
validate: check

# Fix formatting, then run all validation checks
ok: fmt validate
