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

// Only the options set here: an unset one is left to the project's BUILD.thx,
// which any value sent would override.
function settings() {
  const config = vscode.workspace.getConfiguration("thrax");
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
  const config = vscode.workspace.getConfiguration("thrax");
  const server = {
    command: config.get("server.path") || "thrax",
    args: [...config.get("server.extraArgs", []), "lsp"],
  };
  client = new LanguageClient(
    "thrax",
    "Thrax",
    { run: server, debug: server },
    {
      documentSelector: [{ scheme: "file", language: "thrax" }, { scheme: "untitled", language: "thrax" }],
      initializationOptions: settings(),
      outputChannel: output,
      synchronize: {
        fileEvents: vscode.workspace.createFileSystemWatcher("**/*.thx"),
      },
    },
  );
  try {
    await client.start();
  } catch (e) {
    client = undefined;
    const choice = await vscode.window.showErrorMessage(
      `Thrax: could not start \`${server.command} lsp\` (${e.message || e}). Is thrax on your PATH?`,
      "Set thrax.server.path",
    );
    if (choice) vscode.commands.executeCommand("workbench.action.openSettings", "thrax.server.path");
  }
}

async function stop() {
  if (!client) return;
  const c = client;
  client = undefined;
  await c.stop();
}

async function activate(context) {
  output = vscode.window.createOutputChannel("Thrax");
  context.subscriptions.push(
    output,
    vscode.commands.registerCommand("thrax.restartServer", async () => {
      await stop();
      await start();
    }),
    vscode.workspace.onDidChangeConfiguration(async (e) => {
      if (!e.affectsConfiguration("thrax")) return;
      if (e.affectsConfiguration("thrax.server")) {
        await stop();
        await start();
      } else if (client) {
        client.sendNotification("workspace/didChangeConfiguration", { settings: { thrax: settings() } });
      }
    }),
  );
  await start();
}

function deactivate() {
  return stop();
}

module.exports = { activate, deactivate };
