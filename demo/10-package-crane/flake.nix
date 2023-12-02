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
    # Additional input for crane (utility to help building Rust packages)
    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  # Flake outputs
  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        # Define the Rust toolchain
        rustToolchain = pkgs.rust-bin.stable."1.74.0".default.override {
          extensions = [ "rust-src" ];
        };
        # Make the crane library and override the toolchain
        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

        # Use crane to build hello_rs package
        # Note: make sure Cargo.lock is updated using `cargo generate-lockfile`
        hello_rs = craneLib.buildPackage {
          # Source of the package
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          # Build environment dependencies on top of the Rust toolchain
          buildInputs = [
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Additional darwin specific inputs
            pkgs.libiconv
          ];
        };

      in
      {
        # Define packages
        packages.default = hello_rs;

        devShells = {
          # Default development environment
          default = pkgs.mkShell {
            packages = with pkgs; [
              rustToolchain
            ];
          };
          # Environment with the hello_rs installed (similar to `nix shell`)
          installed = pkgs.mkShell {
            packages = [ hello_rs ];
          };
        };
      }
    );
}
