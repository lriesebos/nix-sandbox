{
  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  # Flake outputs
  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryApplication;
        # Make the Poetry application
        foo = mkPoetryApplication { projectDir = self; };

      in
      {
        # Set the default package for `nix shell`
        packages.default = foo;

        devShells.default = pkgs.mkShell {
          # Packages
          packages = with pkgs; [
            # The Poetry environment (i.e. Python environment)
            foo.dependencyEnv
            # Poetry
            pkgs.poetry
          ];
        };
      }
    );
}
