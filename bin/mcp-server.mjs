#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import readline from "node:readline";
import { fileURLToPath } from "node:url";
import { createMcpHandler } from "../src/mcp-core.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PACK_ROOT = path.resolve(__dirname, "..");

if (process.argv.includes("--help") || process.argv.includes("-h")) {
  process.stderr.write(
    "Dev.-DBs-Skills MCP server (stdio JSON-RPC 2.0)\n" +
      "Usage: dev-dbs-skills-mcp\n" +
      "Tools: list_skills, search_skills, get_skill, read_skill_file, install_skills, check_installed_skills\n" +
      "Resources: skill://index.json, skill://<name>/<path>\n" +
      "Prompts: all 113 pack skills exposed as MCP prompts\n",
  );
  process.exit(0);
}

const handleMessage = createMcpHandler(PACK_ROOT);

// Skills are read from disk on every tool call, but prompts/resources are listed by the client at
// startup. Tell the client when the skills folder changes (new or edited skill, git pull) so it can
// refresh without a restart. Started once, after the client sends notifications/initialized.
let watcherStarted = false;
function startSkillsWatcher() {
  if (watcherStarted) return;
  watcherStarted = true;
  const skillsDir = path.join(PACK_ROOT, "skills");
  let timer = null;
  const notifyChanged = () => {
    for (const method of ["notifications/resources/list_changed", "notifications/prompts/list_changed"]) {
      process.stdout.write(`${JSON.stringify({ jsonrpc: "2.0", method })}
`);
    }
  };
  try {
    const watcher = fs.watch(skillsDir, { recursive: true, persistent: false }, () => {
      clearTimeout(timer);
      timer = setTimeout(notifyChanged, 750);
    });
    watcher.on("error", () => {});
  } catch {
    // Recursive watching is not available everywhere; tool calls still read fresh data from disk.
  }
}
const rl = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });
let pending = Promise.resolve();

async function processLine(line) {
  const trimmed = line.trim();
  if (!trimmed) return;

  let msg;
  try {
    msg = JSON.parse(trimmed);
  } catch (err) {
    const parseErr = {
      jsonrpc: "2.0",
      id: null,
      error: { code: -32700, message: `Parse error: ${err instanceof Error ? err.message : String(err)}` },
    };
    process.stdout.write(`${JSON.stringify(parseErr)}\n`);
    return;
  }

  if (msg && msg.method === "notifications/initialized") startSkillsWatcher();
  const response = await handleMessage(msg);
  if (response !== null) {
    process.stdout.write(`${JSON.stringify(response)}\n`);
  }
}

rl.on("line", (line) => {
  pending = pending.then(() => processLine(line)).catch((err) => {
    process.stderr.write(`[dev-dbs-skills-mcp] unexpected error: ${err instanceof Error ? err.stack || err.message : String(err)}\n`);
  });
});

rl.on("close", () => {
  pending.then(() => process.exit(0));
});
