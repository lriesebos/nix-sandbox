{
  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Additional input for flake utils (written in Nix)
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Flake outputs
  outputs = { self, nixpkgs, flake-utils }:
    # Default devshell for default systems (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin) 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          # Packages
          packages = with pkgs; [
            hello
            gcc
            which
            # Python 3.10 with specific packages
            (pkgs.python310.withPackages (ps: with ps; [
              numpy
              flake8
            ]))
          ];
          # Env variables
          MY_VAR = "02-devshell";
        };
      }
    );
}
