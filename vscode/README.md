# Thrax for VS Code

Language support for [Thrax](https://github.com/delyan-kirov/Thrax) through
its language server, `thrax lsp`: ranked diagnostics with quick fixes, hover
types, go to definition, completion, document symbols, formatting and semantic
highlighting. A TextMate grammar highlights before the server is up.

The `thrax` executable must be on your `PATH`, or set `thrax.server.path`.

## Build and install

    npm install
    npx vsce package --allow-missing-repository
    code --install-extension thrax-0.1.0.vsix

## Settings

`thrax.lsp.*`, `thrax.format.*` and `thrax.lints.*` are the options a
project's `BUILD.thx` sets with `@option` (the Thrax language reference,
section 11.4, documents them). A setting left unset defers to the project; a
setting given overrides it. The server is started as
`thrax.server.path [thrax.server.extraArgs] lsp`.

Errors are ranked: the one that matters most in a file is an Error, errors
caused by another one are Information, and errors inside the definition being
typed are held back as Hints until typing pauses. See
`documentation/lsp.md` in the Thrax repository.
