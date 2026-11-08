"use strict";

const vscode = require("vscode");
const { LanguageClient } = require("vscode-languageclient/node");

// The project options an editor may override, by section. The server owns the
// table (crates/utilities/src/config.rs); these mirror package.json.
const OPTIONS = {
  lsp: ["check", "focus", "debounce_ms", "grace", "grace_ms", "max_diagnostics"],
  format: ["width", "indent"],
  lints: ["unreachable_arm"],
};

let client;
let output;

// Only the options set here: an unset one is left to the project's BUILD.ares,
// which any value sent would override.
function settings() {
  const config = vscode.workspace.getConfiguration("ares");
  const out = {};
  for (const [section, keys] of Object.entries(OPTIONS)) {
    for (const key of keys) {
      const value = config.get(`${section}.${key}`);
      if (value === null || value === undefined) continue;
      out[section] = out[section] || {};
      out[section][key] = value;
    }
  }
  return out;
}

async function start() {
  const config = vscode.workspace.getConfiguration("ares");
  const server = {
    command: config.get("server.path") || "ares",
    args: [...config.get("server.extraArgs", []), "lsp"],
  };
  client = new LanguageClient(
    "ares",
    "Ares",
    { run: server, debug: server },
    {
      documentSelector: [{ scheme: "file", language: "ares" }, { scheme: "untitled", language: "ares" }],
      initializationOptions: settings(),
      outputChannel: output,
      synchronize: {
        fileEvents: vscode.workspace.createFileSystemWatcher("**/*.ares"),
      },
    },
  );
  try {
    await client.start();
  } catch (e) {
    client = undefined;
    const choice = await vscode.window.showErrorMessage(
      `Ares: could not start \`${server.command} lsp\` (${e.message || e}). Is ares on your PATH?`,
      "Set ares.server.path",
    );
    if (choice) vscode.commands.executeCommand("workbench.action.openSettings", "ares.server.path");
  }
}

async function stop() {
  if (!client) return;
  const c = client;
  client = undefined;
  await c.stop();
}

async function activate(context) {
  output = vscode.window.createOutputChannel("Ares");
  context.subscriptions.push(
    output,
    vscode.commands.registerCommand("ares.restartServer", async () => {
      await stop();
      await start();
    }),
    vscode.workspace.onDidChangeConfiguration(async (e) => {
      if (!e.affectsConfiguration("ares")) return;
      if (e.affectsConfiguration("ares.server")) {
        await stop();
        await start();
      } else if (client) {
        client.sendNotification("workspace/didChangeConfiguration", { settings: { ares: settings() } });
      }
    }),
  );
  await start();
}

function deactivate() {
  return stop();
}

module.exports = { activate, deactivate };
