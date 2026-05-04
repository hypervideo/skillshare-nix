# skillshare-nix

Nix flake packaging for the [skillshare](https://github.com/runkids/skillshare) CLI.

## Usage

Run the packaged CLI directly:

```bash
nix run github:hypervideo/skillshare-nix -- --help
```

Use it in a development shell:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    skillshare-nix.url = "github:hypervideo/skillshare-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      skillshare-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ skillshare-nix.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.skillshare ];
        };
      }
    );
}
```

## Updating

Run:

```bash
scripts/update-skillshare.sh
nix build
```

The updater checks the latest upstream GitHub release and refreshes all packaged macOS and Linux archive hashes.
