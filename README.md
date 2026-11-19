# Piotr's Nix Flakes

This repo contains my custom Nix flakes. Each program has its own flake and lock file under `flakes/<program>/`.

- [Helium Browser](flakes/helium/README.md)

## Development

Run `devenv shell` to enter the development environment and install the Git pre-commit and pre-push hooks. The hooks format and lint supported files and scan for secrets with Betterleaks.

Formatting uses Nixfmt for Nix, Oxfmt for Markdown/JSON/YAML/TOML, and shfmt for Bash.

- `just fmt` formats Nix, Markdown, JSON, YAML, TOML, and Bash files.
- `just fmt-check` checks formatting without changing files.
- `just lint` runs Statix, Deadnix, and ShellCheck.
- `just validate` runs `devenv test`, which checks formatting and linting.
- `just ok` formats files, then runs validation.

The file checks include tracked and untracked files and respect `.gitignore`.

### MCP-NixOS

The development environment provides Python and `uv` for [MCP-NixOS](https://mcp-nixos.io/). Open this repository as a trusted project in a new Codex session to load its `nixos` MCP server. On first launch, `uvx` fetches the server version specified in `.codex/config.toml` from PyPI. Use it to look up Nixpkgs package names and NixOS or Home Manager options during reviews. Run the commands in each flake's README to verify its pinned inputs and build outputs with Nix.

## Resources / References
- [oxcl - How I packaged a .deb file for NixOS w/ Flakes](https://dev.to/oxcl/how-i-packaged-a-deb-file-for-nixos-with-flakes-5dn)
- [oxcl/nix-flake-helium-browser](https://github.com/oxcl/nix-flake-helium-browser)