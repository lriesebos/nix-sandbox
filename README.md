# Nix sandbox

## Documentation

The following resources might be useful when writing Nix scripts:

- https://nixos.org/manual/nix/unstable/introduction.html
- https://teu5us.github.io/nix-lib.html

## Tools

### Hash for `fetchgit`

Nix `pkgs.fetchgit` requires a sha256 hash. The best way to obtain this hash is by using the `nix-prefetch-git` command and provide the link and git ref (e.g. commit hash or tag) as arguments. For example:

```sh
$ nix-prefetch-git https://gitlab.com/duke-artiq/dax.git v6.7
```

See the Nix environment below.

```nix
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nix-prefetch-git
  ];
}
```

### Linter

Nix linter can sometimes be a bit buggy.

```nix
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nix-linter
  ];
}
```

### Formatter

The official nixpkgs formatter

```nix
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nixpkgs-fmt
  ];
}
```

### Cache

Potential alternatives for a Nix cache (instead of Hydra) are:

- https://nixos.wiki/wiki/Binary_Cache
- https://github.com/helsinki-systems/harmonia
- https://www.cachix.org/
- https://github.com/edolstra/nix-serve
