# Piotr's Nix Flakes

This repo contains my custom Nix flakes. Use the root flake as a single `pflakes` input in NixOS. It exports named modules such as `nixosModules.helium` and packages such as `packages.x86_64-linux.helium`. Each program also has a standalone flake under `flakes/<program>/`.

- [Helium Browser](flakes/helium/README.md)

## Set up GitHub Actions

1. Publish `flakes/helium/` and the [update workflow](.github/workflows/update-helium.yml) together on the default branch. GitHub runs scheduled workflows from that branch. [GitHub schedule documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
2. Open **Settings → Actions → General → Actions permissions** and enable Actions. If you use an allowlist, allow `actions/checkout` and `cachix/install-nix-action`. The workflow requests `contents: write` on the automatic `GITHUB_TOKEN`. You can keep the repository default read-only and leave the secrets list empty. [GitHub Actions settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)
3. Check the default branch protection rules and rulesets. The workflow pushes its update directly. If the branch requires a pull request for every change, the final push will be rejected and the updater will need a pull-request-based workflow.
4. Go to **Actions → Update Helium → Run workflow**, select the default branch, and start a run. Open the run log. When the release pin is current, the release check succeeds and the build and commit steps are skipped. On an update, the workflow builds the x86-64 package, runs `helium --version`, and commits the new pin.

The daily check is scheduled for **06:17 UTC**. Follow the [Helium update instructions](flakes/helium/README.md#updates) to pick up the new pin in nixconfig.

## Development

Run `devenv shell` to enter the development environment and install the Git pre-commit and pre-push hooks. The hooks format and lint supported files and scan for secrets with Betterleaks.

Formatting uses Nixfmt for Nix, Oxfmt for Markdown/JSON/YAML/TOML, and shfmt for Bash.

- `just fmt` formats Nix, Markdown, JSON, YAML, TOML, and Bash files.
- `just fmt-check` checks formatting without changing files.
- `just lint` runs Statix, Deadnix, and ShellCheck.
- `just validate` runs `devenv test`, which checks formatting and linting.
- `just update` updates the custom package pins locally. Currently it runs `just update-helium`.
- `just test-helium` checks the local Helium launcher and reports the result. Add `--launch` to open a browser window with a temporary profile.
- `just ok` formats files, then runs validation.

The file checks include tracked and untracked files and respect `.gitignore`.

### MCP-NixOS

The development environment provides Python and `uv` for [MCP-NixOS](https://mcp-nixos.io/). Open this repository as a trusted project in a new Codex session to load its `nixos` MCP server. On first launch, `uvx` fetches the server version specified in `.codex/config.toml` from PyPI. Use it to look up Nixpkgs package names and NixOS or Home Manager options during reviews. Run the commands in each flake's README to verify its pinned inputs and build outputs with Nix.

## Resources / References

- [oxcl - How I packaged a .deb file for NixOS w/ Flakes](https://dev.to/oxcl/how-i-packaged-a-deb-file-for-nixos-with-flakes-5dn)
- [oxcl/nix-flake-helium-browser](https://github.com/oxcl/nix-flake-helium-browser)
