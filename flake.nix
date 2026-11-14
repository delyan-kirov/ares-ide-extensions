{
  description = "Ares editor tooling: the tree-sitter grammar, and editors set up to build the extensions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, rust-overlay }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      # Zed builds a dev extension with the first `cargo` on PATH, for
      # wasm32-wasip2, which nixpkgs' rustc has no standard library for.
      rust = pkgs.rust-bin.stable.latest.default.override { targets = [ "wasm32-wasip2" ]; };

      # Zed compiles grammars with a wasi-sdk clang it downloads, a generic
      # Linux binary. Under nix-ld it starts but lacks these libraries.
      wasiSdkLibs = pkgs.lib.makeLibraryPath [
        pkgs.ncurses
        pkgs.stdenv.cc.cc.lib
      ];

      zed = pkgs.writeShellScriptBin "zed-ares" ''
        export PATH=${rust}/bin:$PATH
        export NIX_LD_LIBRARY_PATH=${wasiSdkLibs}''${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}
        exec ${pkgs.zed-editor}/bin/zeditor "$@"
      '';

      # `nix run path:tools/editors#zed-build -- DIR`: builds what installing
      # DIR/zed as a dev extension would, in place, so Zed loads it on restart.
      # The grammar is compiled from DIR/tree-sitter-ares as it is on disk (Zed
      # would fetch `rev`), with the wasi-sdk Zed downloaded when there is one.
      zedBuild = pkgs.writeShellScriptBin "zed-build" ''
        set -eu
        dir=''${1:-$PWD}
        export PATH=${rust}/bin:${pkgs.tree-sitter}/bin:$PATH
        export NIX_LD_LIBRARY_PATH=${wasiSdkLibs}''${NIX_LD_LIBRARY_PATH:+:$NIX_LD_LIBRARY_PATH}
        cd "$dir/zed"
        cargo build --quiet --release --target wasm32-wasip2
        cp target/wasm32-wasip2/release/zed_ares.wasm extension.wasm
        mkdir -p grammars
        src=../tree-sitter-ares/src
        clang=''${XDG_DATA_HOME:-$HOME/.local/share}/zed/extensions/build/wasi-sdk/bin/clang
        if [ -x "$clang" ]; then
          "$clang" -fPIC -shared -Os -Wl,--export=tree_sitter_ares \
            -o grammars/ares.wasm -I "$src" "$src/parser.c"
        else
          tree-sitter build --wasm -o grammars/ares.wasm ../tree-sitter-ares
        fi
      '';

      # VS Code is unfree in nixpkgs, so this uses the `code` on PATH.
      vscode = pkgs.writeShellScriptBin "vscode-ares" ''
        dir=''${ARES_EDITORS:-$PWD}/vscode
        [ -d "$dir" ] || dir=$PWD/tools/editors/vscode
        if [ ! -d "$dir/node_modules" ]; then
          ${pkgs.nodejs}/bin/npm --prefix "$dir" install --no-audit --no-fund 1>&2 || exit
        fi
        exec code --extensionDevelopmentPath="$dir" "$@"
      '';
    in
    {
      # `nix run path:tools/editors#zed`: Zed, able to install tools/editors/zed
      # as a dev extension (`zed: install dev extension`).
      # `nix run path:tools/editors#zed-build -- tools/editors`: builds that dev
      # extension in place (`thrax zed-update` runs it).
      # `nix run path:tools/editors#vscode`: VS Code with tools/editors/vscode
      # loaded unpacked; run from the Ares root or tools/editors, or set
      # ARES_EDITORS to tools/editors.
      apps.${system} = {
        zed = {
          type = "app";
          program = "${zed}/bin/zed-ares";
        };
        zed-build = {
          type = "app";
          program = "${zedBuild}/bin/zed-build";
        };
        vscode = {
          type = "app";
          program = "${vscode}/bin/vscode-ares";
        };
      };

      # Regenerating the grammar: TREE_SITTER_GEN.ares writes grammar.js from
      # documentation/syntax/ares.y, and `tree-sitter generate` (which runs grammar.js
      # under node) turns it into the C parser Helix and Zed compile. Packaging
      # the VS Code extension (`npx vsce package`) needs node too, and building
      # the Zed extension by hand (`cargo build --target wasm32-wasip2`) the
      # Rust toolchain.
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.tree-sitter
          pkgs.nodejs
          pkgs.gcc
          rust
        ];
      };
    };
}
