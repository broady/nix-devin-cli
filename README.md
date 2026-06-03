# nix-devin-cli

<!-- version-start -->
**Latest version: 2026.5.26-3**
<!-- version-end -->

[Devin CLI](https://devin.ai) packaged for Nix, with nightly auto-updates.

## Usage

### Via FlakeHub

```bash
fh add cbro/nix-devin-cli
```

### As a flake input

```nix
{
  inputs = {
    nix-devin-cli.url = "github:broady/nix-devin-cli";
  };

  # Then add to your packages:
  # nix-devin-cli.packages.${system}.default
}
```

### One-shot

```bash
# Run without installing
nix run github:broady/nix-devin-cli

# Install to profile
nix profile install github:broady/nix-devin-cli
```

## Supported platforms

- `aarch64-darwin` (Apple Silicon)
- `x86_64-darwin` (Intel Mac)
- `x86_64-linux`
- `aarch64-linux`

## Auto-updates

A [GitHub Action](.github/workflows/update.yml) runs daily to check for new
Devin CLI releases. When a new version is found, it updates `manifest.json`
and pushes a commit. Run `nix flake update` in your consuming flake to pick
up the latest version.

## Manual update

```bash
bash update.sh
```
