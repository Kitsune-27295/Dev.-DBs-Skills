import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const SUPPORTED_PROTOCOL_VERSIONS = ["2025-06-18", "2025-03-26", "2024-11-05"];
const SKILL_NAME_RE = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const MD_LINK_RE = /\]\(([^)#\s]+)(?:#[^)]*)?\)/g;
const BACKTICK_RE = /`([a-z0-9-]+)`/g;
const MAX_DESCRIPTION_LEN = 1024;

/**
 * Parse top-level YAML frontmatter key/value pairs from a SKILL.md string.
 * Supports single-line values and simple folded/multiline scalars inside quotes.
 */
export function parseFrontmatter(text) {
  const clean = text.replace(/^\uFEFF/, "");
  if (!clean.startsWith("---")) return null;
  const firstEnd = clean.indexOf("\n---", 3);
  if (firstEnd === -1) return null;

  const block = clean.slice(3, firstEnd).replace(/^\r?\n/, "");
  const fields = {};
  let currentKey = null;

  for (const rawLine of block.split(/\r?\n/)) {
    const match = rawLine.match(/^([A-Za-z_][\w-]*):\s*(.*)$/);
    if (match) {
      currentKey = match[1];
      fields[currentKey] = match[2].trim();
    } else if (
      currentKey &&
      (rawLine.startsWith("  ") ||
        rawLine.startsWith("\t") ||
        (fields[currentKey].startsWith('"') && !fields[currentKey].endsWith('"')))
    ) {
      fields[currentKey] = `${fields[currentKey]} ${rawLine.trim()}`.trim();
    }
  }

  for (const key of Object.keys(fields)) {
    const val = fields[key];
    if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
      fields[key] = val.slice(1, -1);
    }
  }
  return fields;
}

function listFilesRecursive(dir, baseDir = dir) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...listFilesRecursive(full, baseDir));
    } else if (entry.isFile()) {
      results.push(path.relative(baseDir, full).split(path.sep).join("/"));
    }
  }
  return results.sort((a, b) => a.localeCompare(b));
}

function sha256File(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function treeHashes(dir) {
  const map = new Map();
  for (const rel of listFilesRecursive(dir)) {
    map.set(rel, sha256File(path.join(dir, rel)));
  }
  return map;
}

function mapsEqual(a, b) {
  if (a.size !== b.size) return false;
  for (const [k, v] of a) {
    if (b.get(k) !== v) return false;
  }
  return true;
}

/**
 * Load lightweight skill metadata for every skill under `<packRoot>/skills`.
 */
export function loadCatalog(packRoot) {
  const skillsDir = path.join(packRoot, "skills");
  if (!fs.existsSync(skillsDir)) return [];

  const skills = [];
  for (const entry of fs.readdirSync(skillsDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const skillDir = path.join(skillsDir, entry.name);
    const skillMd = path.join(skillDir, "SKILL.md");
    if (!fs.existsSync(skillMd)) continue;

    const raw = fs.readFileSync(skillMd, "utf8");
    const fm = parseFrontmatter(raw) || {};
    const files = listFilesRecursive(skillDir);
    skills.push({
      name: fm.name || entry.name,
      description: fm.description || "",
      uri: `skill://${entry.name}/SKILL.md`,
      files,
    });
  }
  return skills.sort((a, b) => a.name.localeCompare(b.name));
}

/**
 * Search skills by keyword across name, description, and body content.
 */
export function searchSkills(packRoot, query, limit = 15) {
  const terms = String(query || "")
    .toLowerCase()
    .split(/\s+/)
    .filter(Boolean);
  const catalog = loadCatalog(packRoot);
  if (terms.length === 0) return catalog.slice(0, limit);

  const scored = [];
  for (const skill of catalog) {
    const nameLower = skill.name.toLowerCase();
    const descLower = skill.description.toLowerCase();
    const bodyLower = fs.readFileSync(path.join(packRoot, "skills", skill.name, "SKILL.md"), "utf8").toLowerCase();

    let score = 0;
    for (const term of terms) {
      if (nameLower === term) score += 25;
      else if (nameLower.includes(term)) score += 10;
      if (descLower.includes(term)) score += 5;
      if (bodyLower.includes(term)) score += 2;
    }
    if (score > 0) scored.push({ ...skill, score });
  }

  return scored
    .sort((a, b) => b.score - a.score || a.name.localeCompare(b.name))
    .slice(0, limit);
}

function assertSafeSkillFile(packRoot, name, relPath) {
  if (!SKILL_NAME_RE.test(String(name || ""))) {
    throw new Error(`Invalid skill name: ${name}`);
  }
  const skillDir = path.resolve(packRoot, "skills", name);
  if (!fs.existsSync(skillDir) || !fs.statSync(skillDir).isDirectory()) {
    throw new Error(`Skill not found: ${name}`);
  }
  const normalizedRel = String(relPath || "SKILL.md").replace(/\\/g, "/");
  const resolved = path.resolve(skillDir, normalizedRel);
  if (resolved !== skillDir && !resolved.startsWith(skillDir + path.sep)) {
    throw new Error(`Path traversal rejected: ${relPath}`);
  }
  if (!fs.existsSync(resolved) || !fs.statSync(resolved).isFile()) {
    throw new Error(`File not found in skill ${name}: ${normalizedRel}`);
  }
  return { skillDir, resolved, relPath: normalizedRel };
}

/**
 * Read a skill's SKILL.md and optionally its supplementary markdown/sql files.
 */
export function getSkill(packRoot, name, { includeReferences = false } = {}) {
  const { skillDir, resolved } = assertSafeSkillFile(packRoot, name, "SKILL.md");
  const content = fs.readFileSync(resolved, "utf8");
  const files = listFilesRecursive(skillDir);
  const frontmatter = parseFrontmatter(content) || {};

  const result = {
    name,
    description: frontmatter.description || "",
    uri: `skill://${name}/SKILL.md`,
    files,
    content,
  };

  if (includeReferences) {
    result.attachments = {};
    for (const rel of files) {
      if (rel === "SKILL.md") continue;
      result.attachments[rel] = fs.readFileSync(path.join(skillDir, rel), "utf8");
    }
  }
  return result;
}

/**
 * Read a single relative file inside a skill folder.
 */
export function readSkillFile(packRoot, name, relPath) {
  const { resolved, relPath: normalizedRel } = assertSafeSkillFile(packRoot, name, relPath);
  return {
    name,
    path: normalizedRel,
    uri: `skill://${name}/${normalizedRel}`,
    content: fs.readFileSync(resolved, "utf8"),
  };
}

/**
 * Expand leading `~` and resolve the destination skills folder from scope/agent/targetDir.
 */
export function resolveInstallTarget({ targetDir, scope = "project", agent = "claude", projectDir } = {}) {
  const expandHome = (p) => (p === "~" || p.startsWith("~/") || p.startsWith("~\\") ? path.join(os.homedir(), p.slice(1)) : p);

  if (targetDir) {
    return path.resolve(expandHome(targetDir));
  }

  const baseProject = path.resolve(expandHome(projectDir || process.cwd()));
  if (scope === "user") {
    switch (agent) {
      case "antigravity":
        return path.join(os.homedir(), ".gemini", "config", "skills");
      case "agents":
        return path.join(os.homedir(), ".agents", "skills");
      case "codex":
        return path.join(os.homedir(), ".codex", "skills");
      case "cursor":
        return path.join(os.homedir(), ".cursor", "skills");
      case "claude":
      default:
        return path.join(os.homedir(), ".claude", "skills");
    }
  }

  switch (agent) {
    case "antigravity":
    case "agents":
      return path.join(baseProject, ".agents", "skills");
    case "codex":
      return path.join(baseProject, ".codex", "skills");
    case "cursor":
      return path.join(baseProject, ".cursor", "skills");
    case "claude":
    default:
      return path.join(baseProject, ".claude", "skills");
  }
}

function loadManifest(packRoot) {
  const manifestPath = path.join(packRoot, "MANIFEST.sha256");
  const entries = [];
  if (!fs.existsSync(manifestPath)) return entries;
  for (const line of fs.readFileSync(manifestPath, "utf8").split(/\r?\n/)) {
    const idx = line.indexOf("  ");
    if (idx === -1) continue;
    const digest = line.slice(0, idx);
    const rel = line.slice(idx + 2);
    if (rel.startsWith("skills/")) {
      entries.push({ digest, rel });
    }
  }
  return entries;
}

/**
 * Idempotently install selected (or all) skills into the resolved target folder,
 * matching install_skills.py semantics and verifying copies against MANIFEST.sha256.
 */
export function installSkills(packRoot, { targetDir, scope = "project", agent = "claude", projectDir, skills, force = false, dryRun = false } = {}) {
  const sourceRoot = path.join(packRoot, "skills");
  if (!fs.existsSync(sourceRoot)) {
    throw new Error(`Pack skills directory not found: ${sourceRoot}`);
  }

  const catalog = loadCatalog(packRoot);
  const catalogNames = new Set(catalog.map((s) => s.name));
  const requestedAll = !skills || skills.length === 0 || (skills.length === 1 && skills[0] === "*");
  const selectedNames = requestedAll ? catalog.map((s) => s.name) : [...new Set(skills)];

  for (const name of selectedNames) {
    if (!catalogNames.has(name)) {
      throw new Error(`Unknown skill name: ${name}`);
    }
  }

  const target = resolveInstallTarget({ targetDir, scope, agent, projectDir });
  const installed = [];
  const overwritten = [];
  const upToDate = [];
  const skipped = [];
  const skippedSet = new Set();

  for (const name of selectedNames) {
    const src = path.join(sourceRoot, name);
    const dest = path.join(target, name);
    const exists = fs.existsSync(dest);

    if (exists && mapsEqual(treeHashes(dest), treeHashes(src))) {
      upToDate.push(name);
      continue;
    }
    if (exists && !force) {
      skipped.push(name);
      skippedSet.add(name);
      continue;
    }

    if (exists) overwritten.push(name);
    else installed.push(name);

    if (!dryRun) {
      fs.mkdirSync(target, { recursive: true });
      if (exists) fs.rmSync(dest, { recursive: true, force: true });
      fs.cpSync(src, dest, { recursive: true });
    }
  }

  const problems = [];
  if (!dryRun) {
    const selectedSet = new Set(selectedNames);
    for (const { digest, rel } of loadManifest(packRoot)) {
      const skillName = rel.split("/")[1];
      if (!selectedSet.has(skillName) || skippedSet.has(skillName)) continue;
      const copyPath = path.join(target, rel.slice("skills/".length));
      if (!fs.existsSync(copyPath) || sha256File(copyPath) !== digest) {
        problems.push(`${rel}: SHA-256 verification failed after copying`);
      }
    }
  }

  return {
    ok: problems.length === 0,
    dryRun,
    target,
    requestedCount: selectedNames.length,
    installed,
    overwritten,
    upToDate,
    skipped,
    problems,
  };
}

/**
 * Validate frontmatter, relative Markdown links, and cross-skill references inside a skills directory.
 */
export function checkSkillsFolder(packRoot, targetDir, { strictCrossRefs } = {}) {
  const root = targetDir ? path.resolve(targetDir) : path.join(packRoot, "skills");
  if (!fs.existsSync(root) || !fs.statSync(root).isDirectory()) {
    return { ok: false, root, checkedCount: 0, problems: [`${root}: directory not found`], warnings: [] };
  }

  const packNames = new Set(loadCatalog(packRoot).map((s) => s.name));
  const folders = fs
    .readdirSync(root, { withFileTypes: true })
    .filter((e) => e.isDirectory() && fs.existsSync(path.join(root, e.name, "SKILL.md")))
    .map((e) => e.name)
    .sort((a, b) => a.localeCompare(b));

  if (folders.length === 0) {
    return { ok: false, root, checkedCount: 0, problems: [`${root}: no skill folders with SKILL.md found`], warnings: [] };
  }

  const enforceCrossRefs = strictCrossRefs ?? (!targetDir || folders.length >= packNames.size);
  const installedSet = new Set(folders);
  const problems = [];
  const warnings = [];

  for (const name of folders) {
    const folderPath = path.join(root, name);
    const skillMdPath = path.join(folderPath, "SKILL.md");
    const text = fs.readFileSync(skillMdPath, "utf8");
    const fm = parseFrontmatter(text);
    const where = `${name}/SKILL.md`;

    if (!fm) {
      problems.push(`${where}: missing YAML frontmatter between --- delimiters`);
      continue;
    }
    if (fm.name !== name) {
      problems.push(`${where}: name is ${JSON.stringify(fm.name)}, expected ${JSON.stringify(name)}`);
    }
    if (!SKILL_NAME_RE.test(fm.name || "")) {
      problems.push(`${where}: invalid skill name format`);
    }
    if (!fm.description) {
      problems.push(`${where}: empty description`);
    } else if (fm.description.length > MAX_DESCRIPTION_LEN) {
      problems.push(`${where}: description is ${fm.description.length} chars (limit ${MAX_DESCRIPTION_LEN})`);
    }

    for (const rel of listFilesRecursive(folderPath).filter((f) => f.endsWith(".md"))) {
      const mdPath = path.join(folderPath, rel);
      const mdText = fs.readFileSync(mdPath, "utf8");
      for (const match of mdText.matchAll(MD_LINK_RE)) {
        const target = match[1];
        if (/^[a-z][a-z0-9+.-]*:/i.test(target)) continue;
        const resolved = path.resolve(path.dirname(mdPath), target);
        if (!fs.existsSync(resolved)) {
          problems.push(`${name}/${rel}: link "${target}" does not resolve`);
        }
      }
    }

    const backtickMentions = new Set();
    for (const match of text.matchAll(BACKTICK_RE)) {
      backtickMentions.add(match[1]);
    }
    for (const mention of [...backtickMentions].sort()) {
      if (mention !== name && packNames.has(mention) && !installedSet.has(mention)) {
        const msg = `${where}: refers to \`${mention}\`, which is not installed in ${root}`;
        if (enforceCrossRefs) problems.push(msg);
        else warnings.push(msg);
      }
    }
  }

  return { ok: problems.length === 0, root, checkedCount: folders.length, problems, warnings };
}

const TOOL_DEFINITIONS = [
  {
    name: "list_skills",
    description: "List all skills available in the Dev.-DBs-Skills pack with lightweight metadata (name, description, skill:// URI, and bundled file paths). Supports optional keyword filtering.",
    inputSchema: {
      type: "object",
      properties: {
        query: { type: "string", description: "Optional keyword filter against skill name and description." },
      },
      additionalProperties: false,
    },
  },
  {
    name: "search_skills",
    description: "Search across all 128 Dev.-DBs-Skills by topic, architecture pattern, database engine, security issue, or workflow keyword.",
    inputSchema: {
      type: "object",
      properties: {
        query: { type: "string", description: "Search keywords (e.g. 'hexagonal', 'cqrs', 'webhook idempotency', 'postgres locks', 'tdd')." },
        limit: { type: "integer", minimum: 1, maximum: 128, default: 10, description: "Maximum number of matching skills to return." },
      },
      required: ["query"],
      additionalProperties: false,
    },
  },
  {
    name: "get_skill",
    description: "Load the full SKILL.md instructions for a named skill, plus its list of bundled reference/script files. Use include_references=true only when you also need all supplementary files inline.",
    inputSchema: {
      type: "object",
      properties: {
        name: { type: "string", description: "Exact skill folder name (e.g. 'hexagonal-architecture', 'to-spec', 'security-audit')." },
        include_references: { type: "boolean", default: false, description: "When true, inline all bundled files (references, templates, scripts) in addition to SKILL.md." },
      },
      required: ["name"],
      additionalProperties: false,
    },
  },
  {
    name: "read_skill_file",
    description: "Read a specific supplementary file inside a skill folder (such as references/sources.md, templates, or SQL diagnostic scripts).",
    inputSchema: {
      type: "object",
      properties: {
        name: { type: "string", description: "Skill folder name." },
        path: { type: "string", description: "Relative POSIX path inside the skill folder (e.g. 'references/sources.md')." },
      },
      required: ["name", "path"],
      additionalProperties: false,
    },
  },
  {
    name: "install_skills",
    description: "Install one, several, or all Dev.-DBs-Skills into a project or user skills directory (Claude Code, Antigravity IDE, Codex, Cursor, .agents/skills, or a custom target path) with SHA-256 verification against MANIFEST.sha256.",
    inputSchema: {
      type: "object",
      properties: {
        skills: {
          type: "array",
          items: { type: "string" },
          description: "Skill names to install. Omit or pass ['*'] to install all 128 skills.",
        },
        scope: {
          type: "string",
          enum: ["project", "user"],
          default: "project",
          description: "Install into the project workspace ('project') or the user's global skills folder ('user'). Ignored if target_dir is provided.",
        },
        agent: {
          type: "string",
          enum: ["claude", "antigravity", "agents", "codex", "cursor"],
          default: "claude",
          description: "Target agent convention: project (.claude/skills, .agents/skills, .codex/skills, .cursor/skills) or user (~/.claude/skills, ~/.gemini/config/skills, ~/.agents/skills, ~/.codex/skills, ~/.cursor/skills).",
        },
        project_dir: {
          type: "string",
          description: "Base project directory when scope='project' (defaults to server working directory).",
        },
        target_dir: {
          type: "string",
          description: "Explicit destination directory path (supports '~'). Overrides scope, agent, and project_dir.",
        },
        force: {
          type: "boolean",
          default: false,
          description: "Overwrite existing skills that differ from the pack.",
        },
        dry_run: {
          type: "boolean",
          default: false,
          description: "Preview planned changes without writing to disk.",
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: "check_installed_skills",
    description: "Validate frontmatter, relative Markdown links, and cross-skill references in an installed skills folder (or in this pack's skills/ folder when target_dir is omitted).",
    inputSchema: {
      type: "object",
      properties: {
        target_dir: {
          type: "string",
          description: "Path to the skills folder to validate. Defaults to this pack's skills/ directory.",
        },
        strict_cross_refs: {
          type: "boolean",
          description: "Treat missing cross-referenced pack skills as errors rather than warnings (defaults to true for full pack, false for partial installs).",
        },
      },
      additionalProperties: false,
    },
  },
];

function jsonRpcResult(id, result) {
  return { jsonrpc: "2.0", id, result };
}

function jsonRpcError(id, code, message, data) {
  const error = data === undefined ? { code, message } : { code, message, data };
  return { jsonrpc: "2.0", id, error };
}

function toolSuccess(payload, textOverride) {
  return {
    content: [
      {
        type: "text",
        text: textOverride ?? JSON.stringify(payload, null, 2),
      },
    ],
    structuredContent: payload,
  };
}

function toolFailure(message) {
  return {
    isError: true,
    content: [{ type: "text", text: message }],
  };
}

function parseSkillUri(uri) {
  if (typeof uri !== "string" || !uri.startsWith("skill://")) {
    throw new Error(`Unsupported resource URI: ${uri}`);
  }
  const rest = uri.slice("skill://".length);
  if (rest === "index.json") return { index: true };
  const slash = rest.indexOf("/");
  if (slash === -1) {
    return { index: false, name: rest, filePath: "SKILL.md" };
  }
  return {
    index: false,
    name: rest.slice(0, slash),
    filePath: rest.slice(slash + 1) || "SKILL.md",
  };
}

/**
 * Create a JSON-RPC 2.0 MCP message handler bound to `<packRoot>`.
 * Returns `null` for notifications (messages without an `id`).
 */
export function createMcpHandler(packRoot) {
  const packageJsonPath = path.join(packRoot, "package.json");
  const version = fs.existsSync(packageJsonPath)
    ? JSON.parse(fs.readFileSync(packageJsonPath, "utf8")).version || "1.0.0"
    : "1.0.0";

  return async function handleMessage(msg) {
    if (!msg || typeof msg !== "object" || Array.isArray(msg)) {
      return jsonRpcError(null, -32600, "Invalid Request");
    }

    const { id, method, params } = msg;
    const isNotification = id === undefined || id === null;

    if (typeof method !== "string") {
      return isNotification ? null : jsonRpcError(id, -32600, "Invalid Request: missing method");
    }

    if (method === "notifications/initialized" || method.startsWith("notifications/")) {
      return null;
    }

    try {
      switch (method) {
        case "initialize": {
          const requested = params?.protocolVersion;
          const protocolVersion = SUPPORTED_PROTOCOL_VERSIONS.includes(requested)
            ? requested
            : SUPPORTED_PROTOCOL_VERSIONS[0];
          return jsonRpcResult(id, {
            protocolVersion,
            capabilities: {
              tools: { listChanged: false },
              resources: { subscribe: false, listChanged: true },
              prompts: { listChanged: true },
            },
            serverInfo: {
              name: "dev-dbs-skills",
              version,
            },
            instructions:
              "Expose and install the 128 Dev.-DBs-Skills agent skills. Call list_skills or search_skills to discover relevant skills, get_skill / skill:// resources to load instructions on demand, and install_skills to copy skills locally into a project or user skills directory.",
          });
        }

        case "ping":
          return jsonRpcResult(id, {});

        case "tools/list":
          return jsonRpcResult(id, { tools: TOOL_DEFINITIONS });

        case "tools/call": {
          const toolName = params?.name;
          const args = params?.arguments || {};
          try {
            switch (toolName) {
              case "list_skills": {
                const catalog = loadCatalog(packRoot);
                const q = args.query ? String(args.query).toLowerCase() : "";
                const filtered = q
                  ? catalog.filter((s) => s.name.toLowerCase().includes(q) || s.description.toLowerCase().includes(q))
                  : catalog;
                return jsonRpcResult(id, toolSuccess({ count: filtered.length, skills: filtered }));
              }
              case "search_skills": {
                const matches = searchSkills(packRoot, args.query, args.limit ?? 10);
                return jsonRpcResult(id, toolSuccess({ query: args.query, count: matches.length, matches }));
              }
              case "get_skill": {
                const skill = getSkill(packRoot, args.name, {
                  includeReferences: Boolean(args.include_references),
                });
                return jsonRpcResult(id, toolSuccess(skill, skill.content));
              }
              case "read_skill_file": {
                const file = readSkillFile(packRoot, args.name, args.path);
                return jsonRpcResult(id, toolSuccess(file, file.content));
              }
              case "install_skills": {
                const summary = installSkills(packRoot, {
                  skills: args.skills,
                  scope: args.scope,
                  agent: args.agent,
                  projectDir: args.project_dir,
                  targetDir: args.target_dir,
                  force: Boolean(args.force),
                  dryRun: Boolean(args.dry_run),
                });
                return jsonRpcResult(id, toolSuccess(summary));
              }
              case "check_installed_skills": {
                const report = checkSkillsFolder(packRoot, args.target_dir, {
                  strictCrossRefs: args.strict_cross_refs,
                });
                return jsonRpcResult(id, toolSuccess(report));
              }
              default:
                return jsonRpcError(id, -32602, `Unknown tool: ${toolName}`);
            }
          } catch (err) {
            return jsonRpcResult(id, toolFailure(err instanceof Error ? err.message : String(err)));
          }
        }

        case "resources/list": {
          const catalog = loadCatalog(packRoot);
          const resources = [
            {
              uri: "skill://index.json",
              name: "skills-index",
              title: "Dev.-DBs-Skills Index (128 skills)",
              description: "Machine-readable JSON index of all skills and their bundled files.",
              mimeType: "application/json",
            },
            ...catalog.map((s) => ({
              uri: s.uri,
              name: s.name,
              description: s.description,
              mimeType: "text/markdown",
            })),
          ];
          return jsonRpcResult(id, { resources });
        }

        case "resources/templates/list":
          return jsonRpcResult(id, {
            resourceTemplates: [
              {
                uriTemplate: "skill://{name}/{+path}",
                name: "skill-file",
                description: "Read any file inside a skill folder (e.g. SKILL.md, references/sources.md, scripts/...).",
                mimeType: "text/markdown",
              },
            ],
          });

        case "resources/read": {
          const uri = params?.uri;
          try {
            const parsed = parseSkillUri(uri);
            if (parsed.index) {
              const catalog = loadCatalog(packRoot);
              return jsonRpcResult(id, {
                contents: [
                  {
                    uri: "skill://index.json",
                    mimeType: "application/json",
                    text: JSON.stringify({ count: catalog.length, skills: catalog }, null, 2),
                  },
                ],
              });
            }
            const file = readSkillFile(packRoot, parsed.name, parsed.filePath);
            const mimeType = file.path.endsWith(".json")
              ? "application/json"
              : file.path.endsWith(".sql")
                ? "application/sql"
                : "text/markdown";
            return jsonRpcResult(id, {
              contents: [{ uri, mimeType, text: file.content }],
            });
          } catch (err) {
            return jsonRpcError(id, -32602, err instanceof Error ? err.message : String(err));
          }
        }

        case "prompts/list": {
          const catalog = loadCatalog(packRoot);
          const prompts = catalog.map((s) => ({
            name: s.name,
            description: s.description,
            arguments: [
              {
                name: "context",
                description: "Optional task description, target codebase details, or arguments to apply this skill to.",
                required: false,
              },
            ],
          }));
          return jsonRpcResult(id, { prompts });
        }

        case "prompts/get": {
          const name = params?.name;
          const contextArg = params?.arguments?.context;
          try {
            const skill = getSkill(packRoot, name, { includeReferences: false });
            const textParts = [skill.content.trim()];
            if (skill.files.length > 1) {
              const extras = skill.files.filter((f) => f !== "SKILL.md").map((f) => `- \`skill://${name}/${f}\``).join("\n");
              textParts.push(`\n## Bundled Resources\n${extras}`);
            }
            if (contextArg) {
              textParts.push(`\n## User Task Context\n${contextArg}`);
            }
            return jsonRpcResult(id, {
              description: skill.description,
              messages: [
                {
                  role: "user",
                  content: {
                    type: "text",
                    text: textParts.join("\n"),
                  },
                },
              ],
            });
          } catch (err) {
            return jsonRpcError(id, -32602, err instanceof Error ? err.message : String(err));
          }
        }

        default:
          return isNotification ? null : jsonRpcError(id, -32601, `Method not found: ${method}`);
      }
    } catch (err) {
      return isNotification
        ? null
        : jsonRpcError(id, -32603, err instanceof Error ? err.message : String(err));
    }
  };
}
