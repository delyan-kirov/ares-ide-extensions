# Thrax editor support

Editor integrations for [Thrax](https://github.com/delyan-kirov/Thrax), kept as
the `tools/editors` submodule of the compiler repository. Everything here talks
to the compiler's language server, `thrax lsp`; see `documentation/lsp.md` in
the Thrax repository for what it provides.

| Directory | Editor |
|---|---|
| `vscode/` | VS Code: `nix run path:tools/editors#vscode` (unpacked), or `npm install && npx vsce package --allow-missing-repository` |
| `zed/` | Zed: `nix run path:tools/editors#zed`, then `zed: install dev extension` |
| `neovim/` | Neovim 0.10+: `require("thrax").setup()` |
| `helix/` | Helix: `languages.toml` and highlight queries |
| `tree-sitter-thrax/` | the tree-sitter grammar Helix and Zed parse with, generated |

`TREE_SITTER_GEN.thx` generates the grammar from the Bison spec
`documentation/thrax.y` (`thxdo tree-sitter` from the Thrax root, with the
tree-sitter CLI from `flake.nix`). The output is committed because Zed loads a
grammar only from a git revision.

`thxdo editors-update` brings every editor up to date with the grammar. It pins
`rev` in `zed/extension.toml` to the last commit that changed the grammar (Zed
fetches the grammar at `rev`, and builds a dev extension only from its
extensions page), checks both `highlights.scm` against the grammar, builds
`zed/extension.wasm` and `zed/grammars/thrax.wasm` in place (the `zed-build`
app of `flake.nix`; restart Zed to load them), recompiles Helix's
`thrax.so`, and repackages and reinstalls the VS Code extension. Neovim
compiles nothing. `thxdo edit zed|code|hx` does the part that is stale, then
starts the editor (Zed through `flake.nix`, so it can also build the extension
itself).

`hooks/` are this repository's git hooks (`thxdo hooks` in the Thrax root
installs them). pre-commit checks the highlight queries when the grammar or a
query is staged. post-commit, after a commit that changes the grammar, pins Zed
to it, leaving `zed/extension.toml` for the next commit (a commit cannot name
itself). It and post-checkout and post-merge rebuild what an installed Zed or
Helix uses when it is older than its sources; the Thrax root's hooks do the
same, and its pre-commit refuses a `tools/editors` whose `rev` lags the grammar.

`flake.nix` also starts Zed with what building its extension needs: a Rust
toolchain with the `wasm32-wasip2` target (Zed uses the first `cargo` on PATH,
and nixpkgs' rustc cannot build for it), and, under NixOS's nix-ld, the
libraries the wasi-sdk clang Zed downloads to compile grammars expects
(`libtinfo`, `libstdc++`).

`TAGS.thx` writes a ctags file for Vim and Neovim: `thxdo tags [-o FILE] [PATH...]`.
