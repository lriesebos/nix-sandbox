{
  # Flake inputs
  inputs = {
    nixpkgs.follows = "artiq/nixpkgs";
    artiq.url = "git+https://github.com/m-labs/artiq.git?ref=release-7";
    artiq-comtools.follows = "artiq/artiq-comtools";
    dax = {
      url = git+https://gitlab.com/duke-artiq/dax.git;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        artiqpkgs.follows = "artiq";
        sipyco.follows = "artiq/sipyco";
      };
    };
    dax-comtools = {
      url = git+https://gitlab.com/duke-artiq/dax-comtools.git;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        sipyco.follows = "artiq/sipyco";
      };
    };
    dax-applets = {
      url = git+https://gitlab.com/duke-artiq/dax-applets.git;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        artiqpkgs.follows = "artiq";
      };
    };
    # Example of a non-flake input
    entangler-core-src = {
      url = git+https://gitlab.com/duke-artiq/entangler-core.git;
      flake = false;
    };
  };

  # Flake outputs
  outputs = { self, nixpkgs, artiq, artiq-comtools, dax, dax-comtools, dax-applets, entangler-core-src }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      artiqpkgs = artiq.packages.x86_64-linux // artiq-comtools.packages.x86_64-linux;
      daxpkgs = dax.packages.x86_64-linux // dax-comtools.packages.x86_64-linux // dax-applets.packages.x86_64-linux;
      entangler-core = pkgs.callPackage "${entangler-core-src}/nix/default.nix" { inherit pkgs artiqpkgs; buildGateware = false; };

    in
    {
      # Default development shell
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          # Python packages
          (pkgs.python3.withPackages (ps: [
            # ARTIQ
            artiqpkgs.artiq
            artiqpkgs.artiq-comtools
            # DAX
            daxpkgs.dax
            daxpkgs.dax-comtools
            daxpkgs.dax-applets
            # Entangler core
            entangler-core

            # Test packages
            ps.pytest
            daxpkgs.flake8-artiq

            # Other packages
            ps.autopep8 # for autoformatting
            ps.jsonschema # for generating device db
            ps.paramiko # needed for flashing boards remotely (artiq_flash -H)
          ]))
          # Non-Python packages
          artiqpkgs.openocd-bscanspi # needed for flashing boards, also provides proxy bitstreams
        ];
      };
      # Enables use of `nix fmt`
      formatter.x86_64-linux = pkgs.nixpkgs-fmt;
    };

  # Settings to enable substitution from the M-Labs servers (avoiding local builds)
  nixConfig = {
    extra-trusted-public-keys = [
      "nixbld.m-labs.hk-1:5aSRVA5b320xbNvu30tqxVPXpld73bhtOeH6uAjRyHc="
    ];
    extra-substituters = [ "https://nixbld.m-labs.hk" ];
  };
}
