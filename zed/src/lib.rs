//! Thrax for Zed: starts `thrax lsp` and passes it the user's settings.
//!
//! In Zed's settings, `lsp.thrax.settings` holds the project options to
//! override, by section (`{ "lsp": { "focus": "one" } }`), and
//! `lsp.thrax.binary` may name the executable and its arguments.

use zed_extension_api::{self as zed, serde_json, settings::LspSettings, LanguageServerId, Result};

struct Thrax;

impl zed::Extension for Thrax {
    fn new() -> Self {
        Thrax
    }

    fn language_server_command(&mut self, id: &LanguageServerId, worktree: &zed::Worktree) -> Result<zed::Command> {
        let binary = LspSettings::for_worktree(id.as_ref(), worktree).ok().and_then(|s| s.binary);
        let command = binary
            .as_ref()
            .and_then(|b| b.path.clone())
            .or_else(|| worktree.which("thrax"))
            .ok_or("`thrax` is not on the PATH; set `lsp.thrax.binary.path` in Zed's settings")?;
        let args = binary.as_ref().and_then(|b| b.arguments.clone()).unwrap_or_else(|| vec!["lsp".into()]);
        let mut env = worktree.shell_env();
        if let Some(extra) = binary.and_then(|b| b.env) {
            env.extend(extra);
        }
        Ok(zed::Command { command, args, env })
    }

    // The server reads the same options from both, so the one setting serves.
    fn language_server_initialization_options(
        &mut self,
        id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<serde_json::Value>> {
        Ok(LspSettings::for_worktree(id.as_ref(), worktree).ok().and_then(|s| s.settings))
    }

    fn language_server_workspace_configuration(
        &mut self,
        id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<serde_json::Value>> {
        let settings = LspSettings::for_worktree(id.as_ref(), worktree).ok().and_then(|s| s.settings);
        Ok(settings.map(|s| serde_json::json!({ "thrax": s })))
    }
}

zed::register_extension!(Thrax);
