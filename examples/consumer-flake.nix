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
