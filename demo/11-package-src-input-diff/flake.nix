{
  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Package sources
    gmqtt-src = {
      url = "github:wialon/gmqtt";
      flake = false;
    };
    miniconf-mqtt-src = {
      url = "github:quartiq/miniconf";
      flake = false;
    };
    stabilizer-src = {
      url = "github:quartiq/stabilizer";
      flake = false;
    };
  };

  # Flake outputs
  outputs = { self, nixpkgs, flake-utils, ... } @ extraInputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # gmqtt package
        gmqtt = pkgs.python3Packages.buildPythonPackage {
          pname = "gmqtt";
          version = "0.0.0+g${extraInputs.gmqtt-src.shortRev}";
          src = extraInputs.gmqtt-src;
          checkInputs = with pkgs.python3Packages; [ pytestCheckHook ];
        };
        # miniconf-mqtt package
        miniconf-mqtt = pkgs.python3Packages.buildPythonPackage rec {
          pname = "miniconf-mqtt";
          version = "0.0.0+g${extraInputs.miniconf-mqtt-src.shortRev}";
          src = extraInputs.miniconf-mqtt-src + "/py/${pname}";
          doCheck = false; # no tests
          propagatedBuildInputs = [ gmqtt ];
        };
        # stabilizer package
        stabilizer = pkgs.python3Packages.buildPythonPackage {
          pname = "stabilizer";
          version = "0.0.0+g${extraInputs.stabilizer-src.shortRev}";
          src = extraInputs.stabilizer-src + "/py";
          patches = [ ./stabilizer.diff ];
          doCheck = false; # no tests
          propagatedBuildInputs = (with pkgs.python3Packages; [ numpy scipy matplotlib ]) ++ [ gmqtt miniconf-mqtt ];
        };

      in
      {
        # Packages
        packages = {
          inherit gmqtt miniconf-mqtt stabilizer;
        };

        devShells = {
          # Default devshell
          default = pkgs.mkShell {
            # Packages
            packages = (with pkgs; [
              (pkgs.python3.withPackages (ps: [
                gmqtt
                miniconf-mqtt
                stabilizer
                ps.numpy
                ps.pytest
                ps.autopep8 # for autoformatting
              ]))
              mqttui
            ]);
          };
        };

        # Enables use of `nix fmt`
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
