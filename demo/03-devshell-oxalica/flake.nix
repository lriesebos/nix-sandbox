{
  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Additional input for Rust overlay (i.e. explicit rust toolchains)
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      # "Follow" packages to synchronize packages used by different inputs
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
            hello
            gcc
            which
            (pkgs.python310.withPackages (ps: with ps; [
              numpy
              flake8
            ]))
            # Rust toolchain from the overlay, version 1.65.0 (stable), default profile
            rust-bin.stable."1.65.0".default
          ];
          # Env variables
          MY_VAR = "03-devshell-oxalica";
        };
      }
    );
}
