{
  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Flake outputs
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Default devshell
        devShells.default = pkgs.mkShell {
          # Packages
          packages = with pkgs; [
            nixpkgs-fmt
          ];
        };

        # Enables use of `nix fmt`
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
