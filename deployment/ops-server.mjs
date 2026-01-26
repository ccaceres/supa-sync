#!/usr/bin/env node
/**
 * Lightweight operations server for running local Supabase maintenance scripts.
 *
 * Endpoints (all prefixed with /ops):
 *  - GET  /ops/health               : basic health/status check
 *  - GET  /ops/health/supabase      : check local Supabase container status
 *  - GET  /ops/health/prerequisites : check required env vars and dependencies
 *  - GET  /ops/jobs                 : list recent jobs (includes latest logs)
 *  - GET  /ops/jobs/latest          : fetch the most recent job
 *  - GET  /ops/jobs/:id             : fetch a specific job (with logs)
 *  - POST /ops/jobs/clone           : run deployment/clone-supabase-data.sh
 *  - POST /ops/jobs/install         : run deployment/install-supabase-wsl.sh
 *  - POST /ops/jobs/migrate         : run deployment/apply-migrations.sh
 *
 * Environment:
 *  - Auto-loads .env.ops from project root if it exists
 *  - See .env.ops.sample for all available configuration options
 *
 * Security:
 *  - Bind host defaults to 127.0.0.1 (set OPS_SERVER_HOST=0.0.0.0 to expose)
 *  - Optional bearer header token via OPS_API_TOKEN + X-Ops-Token header
 *
 * Usage:
 *   node deployment/ops-server.mjs
 *   ./deployment/bootstrap.sh  (auto-loads .env.ops)
 */

import http from "http";
import { spawn, execSync } from "child_process";
import fs from "fs";
import os from "os";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");

// ========= .env.ops Loader =========
const loadEnvFile = (filePath) => {
  if (!fs.existsSync(filePath)) return;
  const content = fs.readFileSync(filePath, "utf-8");
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eqIndex = trimmed.indexOf("=");
    if (eqIndex === -1) continue;
    const key = trimmed.slice(0, eqIndex).trim();
    let value = trimmed.slice(eqIndex + 1).trim();
    // Remove surrounding quotes if present
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    // Only set if not already defined in environment
    if (!process.env[key]) {
      process.env[key] = value;
    }
  }
};

// Load .env.ops from project root
loadEnvFile(path.join(repoRoot, ".env.ops"));

const config = {
  port: Number(process.env.OPS_SERVER_PORT || 8731),
  host: process.env.OPS_SERVER_HOST || "127.0.0.1",
  corsOrigin: process.env.OPS_CORS_ORIGIN || "*",
  token: process.env.OPS_API_TOKEN,
  maxJobs: Number(process.env.OPS_MAX_JOBS || 20),
  maxLogLines: Number(process.env.OPS_MAX_LOG_LINES || 2000),
};

const scriptPaths = {
  clone: path.join(repoRoot, "deployment", "clone-supabase-data.sh"),
  install: path.join(repoRoot, "deployment", "install-supabase-wsl.sh"),
  migrate: path.join(repoRoot, "deployment", "apply-migrations.sh"),
};

const jobs = new Map();
let activeJobId = null;

const toIso = () => new Date().toISOString();

const setCors = (res) => {
  res.setHeader("Access-Control-Allow-Origin", config.corsOrigin);
  res.setHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type,X-Ops-Token");
};

const sendJson = (res, status, body) => {
  setCors(res);
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
};

const unauthorized = (res) => sendJson(res, 401, { error: "Unauthorized" });
const notFound = (res) => sendJson(res, 404, { error: "Not found" });

const toWslPath = (inputPath) => {
  // Convert "C:\path\to\repo" -> "/mnt/c/path/to/repo"
  const match = inputPath.match(/^([A-Za-z]):\\(.*)$/);
  if (match) {
    const drive = match[1].toLowerCase();
    const rest = match[2].replace(/\\/g, "/");
    return `/mnt/${drive}/${rest}`;
  }
  return inputPath.replace(/\\/g, "/");
};

const appendLog = (job, level, message) => {
  const lines = message.toString().split(/\r?\n/).filter(Boolean);
  lines.forEach((line) => {
    job.logs.push({ ts: toIso(), level, message: line });
    if (job.logs.length > config.maxLogLines) {
      job.logs.shift();
    }
  });
};

const trimOldJobs = () => {
  if (jobs.size <= config.maxJobs) return;
  const sorted = Array.from(jobs.values())
    .sort((a, b) => new Date(a.startedAt) - new Date(b.startedAt));
  while (sorted.length > config.maxJobs) {
    const jobToRemove = sorted.shift();
    if (jobToRemove) {
      jobs.delete(jobToRemove.id);
    }
  }
};

const buildCommand = (type) => {
  const scriptPath = scriptPaths[type];
  if (!scriptPath || !fs.existsSync(scriptPath)) {
    throw new Error(`Script not found for job type "${type}"`);
  }

  if (process.platform === "win32") {
    const cwd = toWslPath(repoRoot);
    const script = toWslPath(scriptPath);
    return {
      command: "wsl",
      args: ["--cd", cwd, "bash", script],
      env: { ...process.env },
      cwd: repoRoot,
    };
  }

  return {
    command: "bash",
    args: [scriptPath],
    env: { ...process.env },
    cwd: repoRoot,
  };
};

// ========= Health Check Helpers =========

const runCommand = (cmd, args = []) => {
  try {
    const isWindows = process.platform === "win32";
    if (isWindows) {
      // Run command in WSL
      const result = execSync(`wsl ${cmd} ${args.join(" ")}`, {
        encoding: "utf-8",
        timeout: 15000,
        stdio: ["pipe", "pipe", "pipe"],
      });
      return { ok: true, output: result.trim() };
    } else {
      const result = execSync(`${cmd} ${args.join(" ")}`, {
        encoding: "utf-8",
        timeout: 15000,
        stdio: ["pipe", "pipe", "pipe"],
      });
      return { ok: true, output: result.trim() };
    }
  } catch (err) {
    return { ok: false, error: err.message };
  }
};

const checkDocker = () => {
  const result = runCommand("docker", ["info"]);
  if (result.ok) {
    return { ok: true, message: "Docker running" };
  }
  return { ok: false, message: "Docker not running or not installed" };
};

const checkNode = () => {
  try {
    const version = process.version.replace("v", "");
    const major = parseInt(version.split(".")[0], 10);
    if (major >= 18) {
      return { ok: true, message: `Node.js ${version}`, version };
    }
    return { ok: false, message: `Node.js ${version} (v18+ required)`, version };
  } catch {
    return { ok: false, message: "Node.js not detected" };
  }
};

const checkSupabaseKey = () => {
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (key && key.length > 20) {
    return { ok: true, message: "SUPABASE_SERVICE_ROLE_KEY configured" };
  }
  return { ok: false, message: "SUPABASE_SERVICE_ROLE_KEY not set" };
};

const checkSudoPass = () => {
  const pass = process.env.SUDO_PASS;
  if (pass && pass.length > 0) {
    return { ok: true, message: "SUDO_PASS configured" };
  }
  return { ok: false, message: "SUDO_PASS not set (optional for WSL installs)" };
};

const getSupabaseStatus = async () => {
  const result = {
    running: false,
    containers: {},
    ports: {},
    error: null,
  };

  // Check if docker is available first
  const dockerCheck = checkDocker();
  if (!dockerCheck.ok) {
    result.error = "Docker not available";
    return result;
  }

  // Get container status
  const containerResult = runCommand("docker", [
    "ps",
    "-a",
    "--filter", "name=supabase",
    "--format", "{{.Names}}:{{.Status}}"
  ]);

  if (!containerResult.ok) {
    result.error = "Failed to query containers";
    return result;
  }

  const lines = containerResult.output.split("\n").filter(Boolean);
  let runningCount = 0;

  for (const line of lines) {
    const [name, ...statusParts] = line.split(":");
    const status = statusParts.join(":").toLowerCase();
    const shortName = name.replace(/^supabase[-_]/, "").replace(/[-_]\d+$/, "");

    if (status.includes("up")) {
      result.containers[shortName] = "healthy";
      runningCount++;
    } else if (status.includes("exited")) {
      result.containers[shortName] = "exited";
    } else {
      result.containers[shortName] = status.split(" ")[0] || "unknown";
    }
  }

  result.running = runningCount >= 3; // Need at least db, kong, and studio

  // Check expected ports
  const portChecks = [
    { name: "api", port: 54321 },
    { name: "db", port: 54322 },
    { name: "studio", port: 54323 },
  ];

  for (const { name, port } of portChecks) {
    const portResult = runCommand("sh", [
      "-c",
      `ss -lnt 2>/dev/null | grep -q ':${port} ' && echo open || echo closed`
    ]);
    if (portResult.ok && portResult.output === "open") {
      result.ports[name] = port;
    }
  }

  return result;
};

const getPrerequisites = async () => {
  const checks = {
    docker: checkDocker(),
    node: checkNode(),
    supabase_key: checkSupabaseKey(),
    sudo_pass: checkSudoPass(),
  };

  // Check if all required items are OK (sudo_pass is optional)
  const ready = checks.docker.ok && checks.node.ok && checks.supabase_key.ok;

  return { ready, checks };
};

const startJob = (type) => {
  if (activeJobId && jobs.get(activeJobId)?.status === "running") {
    const running = jobs.get(activeJobId);
    return { error: "A job is already running", job: running };
  }

  const id = `${Date.now().toString(36)}-${Math.random()
    .toString(36)
    .slice(2, 8)}`;
  const job = {
    id,
    type,
    status: "running",
    logs: [],
    startedAt: toIso(),
  };

  jobs.set(id, job);
  activeJobId = id;

  let childProcess = null;

  try {
    const cmd = buildCommand(type);
    appendLog(
      job,
      "info",
      `Starting ${type} job with ${cmd.command} (${cmd.args.join(" ")})`
    );

    childProcess = spawn(cmd.command, cmd.args, {
      cwd: cmd.cwd,
      env: cmd.env,
      shell: false,
    });

    job.processId = childProcess.pid;

    childProcess.stdout.on("data", (data) => appendLog(job, "info", data));
    childProcess.stderr.on("data", (data) => appendLog(job, "error", data));

    childProcess.on("error", (err) => {
      appendLog(job, "error", err.message || "Unknown process error");
      job.status = "error";
      job.endedAt = toIso();
      activeJobId = null;
    });

    childProcess.on("close", (code) => {
      job.status = code === 0 ? "success" : "error";
      job.exitCode = code;
      job.endedAt = toIso();
      appendLog(
        job,
        code === 0 ? "info" : "error",
        `Job finished with code ${code}`
      );
      activeJobId = null;
      trimOldJobs();
    });
  } catch (err) {
    appendLog(job, "error", err.message || "Failed to start job");
    job.status = "error";
    job.endedAt = toIso();
    activeJobId = null;
  }

  return { job };
};

const requireAuth = (req, res) => {
  if (!config.token) return true;
  const headerToken = req.headers["x-ops-token"] || req.headers["x-ops-api-token"];
  if (headerToken === config.token) return true;
  unauthorized(res);
  return false;
};

const getJobPayload = (job) =>
  job
    ? {
        ...job,
      }
    : null;

const server = http.createServer(async (req, res) => {
  setCors(res);

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    return res.end();
  }

  const url = new URL(req.url || "/", `http://${req.headers.host}`);
  const segments = url.pathname.split("/").filter(Boolean);

  if (url.pathname === "/ops/health" && req.method === "GET") {
    return sendJson(res, 200, {
      status: "ok",
      activeJobId,
      activeJobStatus: activeJobId ? jobs.get(activeJobId)?.status : null,
      platform: process.platform,
      hostname: os.hostname(),
    });
  }

  // GET /ops/health/supabase - Check local Supabase container status
  if (url.pathname === "/ops/health/supabase" && req.method === "GET") {
    const status = await getSupabaseStatus();
    return sendJson(res, 200, status);
  }

  // GET /ops/health/prerequisites - Check required env vars and dependencies
  if (url.pathname === "/ops/health/prerequisites" && req.method === "GET") {
    const prereqs = await getPrerequisites();
    return sendJson(res, 200, prereqs);
  }

  if (segments[0] !== "ops") {
    return notFound(res);
  }

  if (!requireAuth(req, res)) {
    return;
  }

  // POST /ops/jobs/clone
  if (
    segments[1] === "jobs" &&
    segments[2] === "clone" &&
    req.method === "POST"
  ) {
    const result = startJob("clone");
    if (result.error) {
      return sendJson(res, 409, { error: result.error, job: getJobPayload(result.job) });
    }
    return sendJson(res, 202, { job: getJobPayload(result.job) });
  }

  // POST /ops/jobs/install
  if (
    segments[1] === "jobs" &&
    segments[2] === "install" &&
    req.method === "POST"
  ) {
    const result = startJob("install");
    if (result.error) {
      return sendJson(res, 409, { error: result.error, job: getJobPayload(result.job) });
    }
    return sendJson(res, 202, { job: getJobPayload(result.job) });
  }

  // POST /ops/jobs/migrate - Apply database migrations
  if (
    segments[1] === "jobs" &&
    segments[2] === "migrate" &&
    req.method === "POST"
  ) {
    const result = startJob("migrate");
    if (result.error) {
      return sendJson(res, 409, { error: result.error, job: getJobPayload(result.job) });
    }
    return sendJson(res, 202, { job: getJobPayload(result.job) });
  }

  // GET /ops/jobs/latest
  if (
    segments[1] === "jobs" &&
    segments[2] === "latest" &&
    req.method === "GET"
  ) {
    const latest = Array.from(jobs.values()).sort(
      (a, b) => new Date(b.startedAt) - new Date(a.startedAt)
    )[0];
    return latest
      ? sendJson(res, 200, { job: getJobPayload(latest) })
      : sendJson(res, 404, { error: "No jobs found" });
  }

  // GET /ops/jobs/:id
  if (segments[1] === "jobs" && segments[2] && req.method === "GET") {
    const job = jobs.get(segments[2]);
    if (!job) {
      return notFound(res);
    }
    return sendJson(res, 200, { job: getJobPayload(job) });
  }

  // GET /ops/jobs
  if (segments[1] === "jobs" && !segments[2] && req.method === "GET") {
    const list = Array.from(jobs.values()).sort(
      (a, b) => new Date(b.startedAt) - new Date(a.startedAt)
    );
    return sendJson(res, 200, { jobs: list.map(getJobPayload) });
  }

  return notFound(res);
});

server.listen(config.port, config.host, () => {
  console.log(
    `[ops-server] listening on http://${config.host}:${config.port} (platform=${process.platform})`
  );
});
