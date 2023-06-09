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
    let
      # Overlays enable you to customize the nixpkgs attribute set
      overlays = [
        # Makes a `rust-bin` attribute available in nixpkgs
        (import rust-overlay)
        # Provides a `rustToolchain` attribute for nixpkgs that we can use to create a Rust environment
        (self: super: {
          rustToolchain = super.rust-bin.stable."1.65.0".default.override {
            extensions = [ "rust-src" ];
            targets = [ "aarch64-unknown-linux-gnu" ];
          };
        })
      ];

      # Helper to generate bindgen extra clang args
      bindgenArgs = pkgs:
        # Includes with normal include path
        (builtins.map (a: ''-I"${a}/include"'') [
          (if pkgs.stdenv.isDarwin then pkgs.darwin.Libc else pkgs.glibc.dev)
        ])
        # Includes with special directory paths
        ++ [
          ''-I"${pkgs.libclang.lib}/lib/clang/${pkgs.libclang.version}/include"''
        ];

    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };

        # Development packages
        devPkgs = (with pkgs; [
          nixpkgs-fmt
        ]);

        # Rust packages
        rustPkgs = (with pkgs; [
          rustToolchain # Rust toolchain from the overlay
          cargo-zigbuild
          libclang
        ]) ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
          libiconv
        ]);

        # Python packages for scripts
        pythonPkgs = [
          (pkgs.python310.withPackages (ps: with ps; [
            numpy
            pillow
            paramiko
            scp
            requests
            autopep8
            flake8
          ]))
        ];

      in
      {
        # Default devshell
        devShells.default = pkgs.mkShell {
          # Packages
          packages = devPkgs ++ rustPkgs ++ pythonPkgs;
          # Add libclang path for bindgen
          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.libclang.lib ];
          # Add headers to bindgen extra clang args
          BINDGEN_EXTRA_CLANG_ARGS = bindgenArgs pkgs;
        };

        # Cross compilation devshell for aarch64
        devShells.cross = pkgs.mkShell {
          # Packages
          packages = rustPkgs;
          # Add libclang path for bindgen
          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.libclang.lib ];
          # Add headers to bindgen extra clang args
          BINDGEN_EXTRA_CLANG_ARGS_aarch64_unknown_linux_gnu = bindgenArgs (import nixpkgs { system = "aarch64-linux"; });
        };

        # Python devshell
        devShells.python = pkgs.mkShell {
          # Packages
          packages = pythonPkgs;
        };
      }
    );
}
