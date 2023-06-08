{
  # Flake inputs
  inputs = {
    # Latest Nix packages collection from https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # Flake outputs
  outputs = { self, nixpkgs }:
    {
      # Default devshell for x86_64-linux
      devShells.x86_64-linux.default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.mkShell {
          # Packages
          packages = with pkgs; [ hello gcc which ];
          # Env variables
          MY_VAR = "01-devshell";
        };
    };
}
