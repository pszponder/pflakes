set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# List available recipes
default:
    @just --list

# Smoke-test local Helium; add --launch to open a test window
[arg("launch", long, value="--launch")]
test-helium launch="":
    @bash scripts/test-helium.sh {{quote(launch)}}

# Update all custom package pins
update: update-helium

# Check upstream and smoke-test Helium before updating its release pin
update-helium:
    @bash scripts/update-helium.sh

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
