{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell rec {
          buildInputs = with pkgs; ([
            podman-compose
          ]);

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
          '';
        };

        env = {
          # Workaround in linux: python downloads ELF's that can't find glibc
          # You would see errors like: error while loading shared libraries: name.so: cannot open shared object file: No such file or directory
          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
          # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          #   pkgs.stdenv.cc.cc
          #   # Add any missing library needed
          #   # You can use the nix-index package to locate them, e.g. nix-locate -w --top-level --at-root /lib/libudev.so.1
          # ];

          # Put the venv on the repo, so direnv can access it
          POETRY_VIRTUALENVS_IN_PROJECT = "true";
          POETRY_VIRTUALENVS_PATH = "{project-dir}/.venv";

          # Use python from path, so you can use a different version to the one bundled with poetry
          POETRY_VIRTUALENVS_PREFER_ACTIVE_PYTHON = "true";
        };
      }
    );
}

