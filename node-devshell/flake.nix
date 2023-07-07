{
  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  # Flake outputs
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Define overlays (i.e. replacement packages)
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        devShells.default = pkgs.mkShell {
          # Packages
          packages = with pkgs; [
            git
            yarn
            nodejs_18
            go_1_19
            (pkgs.python311.withPackages (ps: with ps; [
              numpy
            ]))
            (rust-bin.stable."1.70.0".default.override { extensions = [ "rust-src" ]; })
          ];
        };
      }
    );
}
