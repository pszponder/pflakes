# Piotr's Nix Flakes

This repo contains my custom nix flakes

Run `devenv shell` to enter the development environment and install the Git
pre-commit and pre-push hooks. The hooks format and lint supported files and
scan for secrets with Betterleaks.

Formatting uses Nixfmt for Nix, Oxfmt for Markdown/JSON/YAML/TOML,
and shfmt for Bash.

- `just fmt` formats Nix, Markdown, JSON, YAML, TOML, and Bash files.
- `just fmt-check` checks formatting without changing files.
- `just lint` runs Statix, Deadnix, and ShellCheck.
- `just validate` runs `devenv test`, which checks formatting and linting.
- `just ok` formats files, then runs validation.

The file checks include tracked and untracked files and respect `.gitignore`.
