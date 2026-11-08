# Ares for VS Code

Language support for [Ares](https://github.com/delyan-kirov/Ares) through
its language server, `ares lsp`: ranked diagnostics with quick fixes, hover
types, go to definition, completion, document symbols, formatting and semantic
highlighting. A TextMate grammar highlights before the server is up.

The `ares` executable must be on your `PATH`, or set `ares.server.path`.

## Build and install

    npm install
    npx vsce package --allow-missing-repository
    code --install-extension ares-0.1.0.vsix

## Settings

`ares.lsp.*`, `ares.format.*` and `ares.lints.*` are the options a
project's `BUILD.ares` sets with `@option` (the Ares language reference,
section 11.4, documents them). A setting left unset defers to the project; a
setting given overrides it. The server is started as
`ares.server.path [ares.server.extraArgs] lsp`.

Errors are ranked: the one that matters most in a file is an Error, errors
caused by another one are Information, and errors inside the definition being
typed are held back as Hints until typing pauses. See
`documentation/lsp.md` in the Ares repository.
