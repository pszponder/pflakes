set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# List available recipes
default:
    @just --list

# Smoke-test local Helium; add --launch to open a test window
[arg("launch", long, value="--launch")]
test-helium launch="":
    @bash scripts/test-helium.sh {{quote(launch)}}

# Smoke-test local Zen Browser; add --launch to open a test window
[arg("launch", long, value="--launch")]
test-zen-browser launch="":
    @bash scripts/test-zen-browser.sh {{quote(launch)}}

# Update all custom package pins
update: update-helium update-zen-browser

# Check upstream and smoke-test Helium before updating its release pin
update-helium:
    @bash scripts/update-helium.sh

# Refresh the official Zen release pin and smoke-test both flake outputs
update-zen-browser:
    @bash scripts/update-zen-browser.sh

# Format supported files
fmt:
    bash scripts/format.sh

# Check formatting without changing files
fmt-check:
    bash scripts/format.sh --check

# Lint Nix and Bash files
lint:
    bash scripts/lint.sh

# Evaluate the development environment and run its formatting and lint checks
check:
    devenv test

# Run all validation checks
validate: check

# Fix formatting, then run all validation checks
ok: fmt validate
