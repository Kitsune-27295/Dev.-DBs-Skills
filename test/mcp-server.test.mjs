import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { createMcpHandler } from "../src/mcp-core.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PACK_ROOT = path.resolve(__dirname, "..");

test("MCP initialize, tools/list, resources/list, and prompts/list expose all 87 skills", async () => {
  const handle = createMcpHandler(PACK_ROOT);

  const init = await handle({
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: { protocolVersion: "2025-03-26", capabilities: {}, clientInfo: { name: "test", version: "1.0.0" } },
  });
  assert.equal(init.result.protocolVersion, "2025-03-26");
  assert.equal(init.result.serverInfo.name, "dev-dbs-skills");
  assert.ok(init.result.capabilities.tools);
  assert.ok(init.result.capabilities.resources);
  assert.ok(init.result.capabilities.prompts);

  const notif = await handle({ jsonrpc: "2.0", method: "notifications/initialized" });
  assert.equal(notif, null);

  const toolsRes = await handle({ jsonrpc: "2.0", id: 2, method: "tools/list" });
  const toolNames = toolsRes.result.tools.map((t) => t.name);
  assert.deepEqual(toolNames, [
    "list_skills",
    "search_skills",
    "get_skill",
    "read_skill_file",
    "install_skills",
    "check_installed_skills",
  ]);

  const listCall = await handle({ jsonrpc: "2.0", id: 3, method: "tools/call", params: { name: "list_skills", arguments: {} } });
  assert.equal(listCall.result.structuredContent.count, 87);

  const resourcesRes = await handle({ jsonrpc: "2.0", id: 4, method: "resources/list" });
  assert.equal(resourcesRes.result.resources[0].uri, "skill://index.json");
  assert.equal(resourcesRes.result.resources.length, 88);

  const promptsRes = await handle({ jsonrpc: "2.0", id: 5, method: "prompts/list" });
  assert.equal(promptsRes.result.prompts.length, 87);
});

test("MCP skill consumption tools, resources, prompts, and traversal protection", async () => {
  const handle = createMcpHandler(PACK_ROOT);

  const searchRes = await handle({
    jsonrpc: "2.0",
    id: 10,
    method: "tools/call",
    params: { name: "search_skills", arguments: { query: "hexagonal", limit: 5 } },
  });
  assert.equal(searchRes.result.structuredContent.matches[0].name, "hexagonal-architecture");

  const getRes = await handle({
    jsonrpc: "2.0",
    id: 11,
    method: "tools/call",
    params: { name: "get_skill", arguments: { name: "grill-me" } },
  });
  assert.match(getRes.result.content[0].text, /grilling/);
  assert.doesNotMatch(getRes.result.content[0].text, /disable-model-invocation/);

  const readRef = await handle({
    jsonrpc: "2.0",
    id: 12,
    method: "tools/call",
    params: { name: "read_skill_file", arguments: { name: "to-spec", path: "references/sources.md" } },
  });
  assert.match(readRef.result.content[0].text, /Matt Pocock/);

  const traversalRes = await handle({
    jsonrpc: "2.0",
    id: 13,
    method: "tools/call",
    params: { name: "read_skill_file", arguments: { name: "to-spec", path: "../../package.json" } },
  });
  assert.equal(traversalRes.result.isError, true);
  assert.match(traversalRes.result.content[0].text, /Path traversal rejected/);

  const resRead = await handle({
    jsonrpc: "2.0",
    id: 14,
    method: "resources/read",
    params: { uri: "skill://index.json" },
  });
  const indexPayload = JSON.parse(resRead.result.contents[0].text);
  assert.equal(indexPayload.count, 87);

  const promptRes = await handle({
    jsonrpc: "2.0",
    id: 15,
    method: "prompts/get",
    params: { name: "to-spec", arguments: { context: "Build billing webhook pipeline" } },
  });
  assert.match(promptRes.result.messages[0].content.text, /Build billing webhook pipeline/);
});

test("MCP install_skills and check_installed_skills handle dry_run, idempotency, force, and SHA-256 verification", async () => {
  const handle = createMcpHandler(PACK_ROOT);
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "dev-dbs-mcp-test-"));

  try {
    const dryRun = await handle({
      jsonrpc: "2.0",
      id: 20,
      method: "tools/call",
      params: {
        name: "install_skills",
        arguments: { skills: ["grill-me", "grilling"], project_dir: tmpDir, agent: "antigravity", dry_run: true },
      },
    });
    assert.deepEqual(dryRun.result.structuredContent.installed, ["grill-me", "grilling"]);
    assert.equal(fs.existsSync(path.join(tmpDir, ".agents", "skills", "grill-me")), false);

    const firstInstall = await handle({
      jsonrpc: "2.0",
      id: 21,
      method: "tools/call",
      params: {
        name: "install_skills",
        arguments: { skills: ["grill-me", "grilling"], project_dir: tmpDir, agent: "antigravity" },
      },
    });
    assert.equal(firstInstall.result.structuredContent.ok, true);
    assert.deepEqual(firstInstall.result.structuredContent.installed, ["grill-me", "grilling"]);
    assert.ok(fs.existsSync(path.join(tmpDir, ".agents", "skills", "grill-me", "SKILL.md")));

    const repeatInstall = await handle({
      jsonrpc: "2.0",
      id: 22,
      method: "tools/call",
      params: {
        name: "install_skills",
        arguments: { skills: ["grill-me", "grilling"], project_dir: tmpDir, agent: "antigravity" },
      },
    });
    assert.deepEqual(repeatInstall.result.structuredContent.upToDate, ["grill-me", "grilling"]);

    const installedFile = path.join(tmpDir, ".agents", "skills", "grill-me", "SKILL.md");
    fs.appendFileSync(installedFile, "\n<!-- local edit -->\n", "utf8");

    const skippedInstall = await handle({
      jsonrpc: "2.0",
      id: 23,
      method: "tools/call",
      params: {
        name: "install_skills",
        arguments: { skills: ["grill-me", "grilling"], project_dir: tmpDir, agent: "antigravity", force: false },
      },
    });
    assert.deepEqual(skippedInstall.result.structuredContent.skipped, ["grill-me"]);

    const forcedInstall = await handle({
      jsonrpc: "2.0",
      id: 24,
      method: "tools/call",
      params: {
        name: "install_skills",
        arguments: { skills: ["grill-me", "grilling"], project_dir: tmpDir, agent: "antigravity", force: true },
      },
    });
    assert.equal(forcedInstall.result.structuredContent.ok, true);
    assert.deepEqual(forcedInstall.result.structuredContent.overwritten, ["grill-me"]);

    const checkRes = await handle({
      jsonrpc: "2.0",
      id: 25,
      method: "tools/call",
      params: {
        name: "check_installed_skills",
        arguments: { target_dir: path.join(tmpDir, ".agents", "skills") },
      },
    });
    assert.equal(checkRes.result.structuredContent.ok, true);
    assert.equal(checkRes.result.structuredContent.checkedCount, 2);
    assert.ok(checkRes.result.structuredContent.warnings.length > 0);

    const strictCheck = await handle({
      jsonrpc: "2.0",
      id: 26,
      method: "tools/call",
      params: {
        name: "check_installed_skills",
        arguments: { target_dir: path.join(tmpDir, ".agents", "skills"), strict_cross_refs: true },
      },
    });
    assert.equal(strictCheck.result.structuredContent.ok, false);
    assert.ok(strictCheck.result.structuredContent.problems.length > 0);

    const packCheck = await handle({
      jsonrpc: "2.0",
      id: 27,
      method: "tools/call",
      params: { name: "check_installed_skills", arguments: {} },
    });
    assert.equal(packCheck.result.structuredContent.ok, true);
    assert.equal(packCheck.result.structuredContent.checkedCount, 87);
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

test("bin/mcp-server.mjs handles JSON-RPC over real stdio", async () => {
  const child = spawn(process.execPath, [path.join(PACK_ROOT, "bin", "mcp-server.mjs")], {
    cwd: PACK_ROOT,
    stdio: ["pipe", "pipe", "pipe"],
  });

  let stdout = "";
  let stderr = "";
  child.stdout.on("data", (chunk) => {
    stdout += chunk.toString("utf8");
  });
  child.stderr.on("data", (chunk) => {
    stderr += chunk.toString("utf8");
  });

  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id: 1, method: "initialize", params: { protocolVersion: "2024-11-05" } })}\n`);
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" })}\n`);
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id: 2, method: "ping" })}\n`);
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id: 3, method: "unknown/method" })}\n`);
  child.stdin.end();

  const exitCode = await new Promise((resolve) => child.on("close", resolve));
  assert.equal(exitCode, 0, `stderr: ${stderr}`);

  const lines = stdout
    .trim()
    .split(/\r?\n/)
    .map((line) => JSON.parse(line));
  assert.equal(lines.length, 3);
  assert.equal(lines[0].id, 1);
  assert.equal(lines[0].result.serverInfo.name, "dev-dbs-skills");
  assert.equal(lines[1].id, 2);
  assert.deepEqual(lines[1].result, {});
  assert.equal(lines[2].id, 3);
  assert.equal(lines[2].error.code, -32601);
});
