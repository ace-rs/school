#!/usr/bin/env node

import { spawn } from "node:child_process";
import fs from "node:fs";
import net from "node:net";
import os from "node:os";
import path from "node:path";
import process from "node:process";

const args = parseArgs(process.argv.slice(2));
const cwd = path.resolve(args.cwd ?? process.cwd());
const socketDir = path.resolve(
  args.socketDir ?? process.env.XDG_RUNTIME_DIR ?? path.join(os.homedir(), ".ace", "run"),
  args.socketDir ? "" : "messages",
);
const workspace = path.basename(cwd) || "workspace";
const slug = args.slug ?? `${workspace}.codex-app`;
const socketPath = path.join(socketDir, `${slug}.sock`);
const model = args.model ?? "gpt-5.4-mini";
const effort = args.effort ?? "low";
const sandbox = args.sandbox ?? "workspace-write";
const approvalPolicy = args.approvalPolicy ?? "never";
const captureOutput = args.captureOutput ?? !args.appUrl;
const waitForLoadedThreadFlag = readBooleanFlag(args.waitForLoadedThread);
const loadedThreadTimeoutMs = readPositiveInteger(
  args.loadedThreadTimeoutMs ?? 60_000,
  "--loaded-thread-timeout-ms",
);
const loadedThreadPollTimeoutMs = readPositiveInteger(
  args.loadedThreadPollTimeoutMs ?? 2_000,
  "--loaded-thread-poll-timeout-ms",
);

let appServer = null;
let ws = null;
let threadId = null;
let nextRequestId = 1;
const pendingRequests = new Map();
const pendingTurns = new Map();
const queue = [];
let processing = false;

main().catch((error) => {
  console.error(error?.stack ?? String(error));
  cleanup();
  process.exitCode = 1;
});

async function main() {
  fs.mkdirSync(socketDir, { recursive: true, mode: 0o700 });
  fs.chmodSync(socketDir, 0o700);

  const appUrl = args.appUrl ?? await startAppServer();
  ws = await connectAppServer(appUrl);
  threadId = await selectThread();

  await listenForAceMessages();
  console.log(`ace-connect codex app bridge listening slug=${slug} socket=${socketPath}`);
  console.log(`codex app-server=${appUrl} thread=${threadId} model=${model} effort=${effort}`);
}

function parseArgs(argv) {
  const parsed = {};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (!arg.startsWith("--")) {
      throw new Error(`unexpected argument: ${arg}`);
    }

    const key = arg.slice(2).replaceAll("-", "_");
    const next = argv[index + 1];
    if (!next || next.startsWith("--")) {
      parsed[toCamel(key)] = true;
      continue;
    }

    parsed[toCamel(key)] = next;
    index += 1;
  }
  return parsed;
}

function toCamel(value) {
  return value.replace(/_([a-z])/g, (_, char) => char.toUpperCase());
}

function readBooleanFlag(value) {
  return value === true || value === "true" || value === "1";
}

function readPositiveInteger(value, flagName) {
  if (value === true) {
    throw new Error(`${flagName} requires a positive integer value`);
  }

  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`${flagName} must be a positive integer, got: ${value}`);
  }

  return parsed;
}

function startAppServer() {
  return new Promise((resolve, reject) => {
    appServer = spawn("codex", ["app-server", "--listen", "ws://127.0.0.1:0"], {
      cwd,
      stdio: ["ignore", "pipe", "pipe"],
    });

    const timer = setTimeout(() => {
      reject(new Error("timed out waiting for codex app-server startup"));
    }, 10_000);

    const handleOutput = (chunk) => {
      const output = chunk.toString("utf8");
      process.stderr.write(output);

      const match = output.match(/listening on:\s+(ws:\/\/127\.0\.0\.1:\d+)/);
      if (match) {
        clearTimeout(timer);
        resolve(match[1]);
      }
    };

    appServer.stdout.on("data", handleOutput);
    appServer.stderr.on("data", handleOutput);
    appServer.once("error", reject);
    appServer.once("exit", (code, signal) => {
      reject(new Error(`codex app-server exited before ready: code=${code} signal=${signal}`));
    });
  });
}

function connectAppServer(url) {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(url);

    socket.addEventListener("open", () => {
      socket.addEventListener("message", handleAppServerMessage);
      request(socket, "initialize", {
        clientInfo: { name: "ace-connect-codex-app-bridge", version: "0" },
        capabilities: { experimentalApi: true },
      })
        .then(() => {
          socket.send(JSON.stringify({ method: "initialized" }));
          resolve(socket);
        })
        .catch(reject);
    });

    socket.addEventListener("error", (event) => {
      reject(new Error(`websocket error: ${event.message ?? "unknown error"}`));
    });
  });
}

async function startThread() {
  const result = await request(ws, "thread/start", {
    cwd,
    model,
    approvalPolicy,
    sandbox,
  });
  return result.thread.id;
}

async function selectThread() {
  if (args.threadId) {
    if (captureOutput) {
      await resumeThread(args.threadId);
    }
    return args.threadId;
  }

  if (args.appUrl) {
    const selectedThreadId = await selectAppUrlThread();
    if (captureOutput) {
      await resumeThread(selectedThreadId);
    }
    return selectedThreadId;
  }

  return startThread();
}

async function selectAppUrlThread() {
  if (waitForLoadedThreadFlag) {
    return waitForLoadedThread();
  }

  const loadedThreads = await listLoadedThreads();
  if (loadedThreads.length === 1) {
    return loadedThreads[0];
  }

  if (loadedThreads.length > 1) {
    const choices = loadedThreads.join(", ");
    throw new Error(`multiple loaded Codex threads; pass --thread-id explicitly: ${choices}`);
  }

  return startThread();
}

async function waitForLoadedThread() {
  const deadline = Date.now() + loadedThreadTimeoutMs;
  let lastError = null;

  while (Date.now() < deadline) {
    let loadedThreads = [];
    try {
      loadedThreads = await listLoadedThreads();
      lastError = null;
    } catch (error) {
      lastError = error;
      console.error(`waiting for loaded Codex thread: ${error.message}`);
    }

    if (loadedThreads.length === 1) {
      return loadedThreads[0];
    }

    if (loadedThreads.length > 1) {
      const choices = loadedThreads.join(", ");
      throw new Error(`multiple loaded Codex threads; pass --thread-id explicitly: ${choices}`);
    }

    const remainingMs = deadline - Date.now();
    if (remainingMs > 0) {
      await sleep(Math.min(250, remainingMs));
    }
  }

  const lastErrorText = lastError ? `; last error: ${lastError.message}` : "";
  throw new Error(
    `timed out waiting ${loadedThreadTimeoutMs}ms for a loaded Codex TUI thread${lastErrorText}`,
  );
}

async function listLoadedThreads() {
  const result = await request(ws, "thread/loaded/list", {}, {
    timeoutMs: loadedThreadPollTimeoutMs,
  });
  return result.data ?? [];
}

function sleep(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function resumeThread(selectedThreadId) {
  await request(ws, "thread/resume", {
    threadId: selectedThreadId,
    excludeTurns: true,
  });
}

function listenForAceMessages() {
  return new Promise((resolve, reject) => {
    fs.rmSync(socketPath, { force: true });

    const server = net.createServer((connection) => {
      let data = "";
      connection.setEncoding("utf8");
      connection.on("data", (chunk) => {
        data += chunk;
      });
      connection.on("end", () => {
        const line = data.trim();
        if (line) {
          queue.push(line);
          processQueue().catch((error) => console.error(error?.stack ?? String(error)));
        }
      });
    });

    server.once("error", reject);
    server.listen(socketPath, () => {
      fs.chmodSync(socketPath, 0o700);
      resolve();
    });

    process.once("SIGINT", () => {
      server.close();
      cleanup();
      process.exit(130);
    });
    process.once("SIGTERM", () => {
      server.close();
      cleanup();
      process.exit(143);
    });
  });
}

async function processQueue() {
  if (processing) {
    return;
  }

  processing = true;
  try {
    while (queue.length > 0) {
      const line = queue.shift();
      await handleAceLine(line);
    }
  } finally {
    processing = false;
  }
}

async function handleAceLine(line) {
  console.log(`ace-connect received ${line}`);

  const message = parseWireLine(line);
  const prompt = [
    "You received an ace-connect message from another local agent.",
    "Act on the body as the user request for this turn.",
    "Keep the final response concise because it will be sent back over one line.",
    "",
    `Raw line: ${line}`,
    `Body: ${message.body ?? ""}`,
  ].join("\n");

  const finalText = await runTurn(prompt);
  console.log(`codex final ${finalText}`);

  if (message.from) {
    sendReply(message.from, finalText);
  }
}

function parseWireLine(line) {
  const fields = {};
  for (const field of line.split("\t")) {
    const separator = field.indexOf("=");
    if (separator === -1) {
      continue;
    }

    const key = field.slice(0, separator);
    const value = field.slice(separator + 1);
    fields[key] = value;
  }
  return fields;
}

async function runTurn(prompt) {
  const result = await request(ws, "turn/start", {
    threadId,
    effort,
    input: [{ type: "text", text: prompt }],
  });

  const turnId = result.turn.id;
  if (!captureOutput) {
    return `delivered to Codex thread ${threadId} turn ${turnId}`;
  }

  return new Promise((resolve, reject) => {
    pendingTurns.set(turnId, { text: "", resolve, reject });
  });
}

function request(socket, method, params, options = {}) {
  const id = nextRequestId;
  nextRequestId += 1;

  const payload = { jsonrpc: "2.0", id, method, params };
  return new Promise((resolve, reject) => {
    let timer = null;
    const settle = (callback, value) => {
      if (timer) {
        clearTimeout(timer);
      }
      callback(value);
    };

    pendingRequests.set(id, {
      resolve: (value) => settle(resolve, value),
      reject: (error) => settle(reject, error),
    });

    if (options.timeoutMs) {
      timer = setTimeout(() => {
        pendingRequests.delete(id);
        reject(new Error(`${method} timed out after ${options.timeoutMs}ms`));
      }, options.timeoutMs);
    }

    socket.send(JSON.stringify(payload));
  });
}

function handleAppServerMessage(event) {
  const message = JSON.parse(event.data);

  if (Object.hasOwn(message, "id")) {
    const pending = pendingRequests.get(message.id);
    if (!pending) {
      return;
    }

    pendingRequests.delete(message.id);
    if (message.error) {
      pending.reject(new Error(JSON.stringify(message.error)));
    } else {
      pending.resolve(message.result);
    }
    return;
  }

  if (message.method === "item/agentMessage/delta") {
    const turn = pendingTurns.get(message.params.turnId);
    if (turn) {
      turn.text += message.params.delta;
    }
    return;
  }

  if (message.method === "item/completed") {
    const item = message.params.item;
    const turn = pendingTurns.get(message.params.turnId);
    if (turn && item.type === "agentMessage" && item.text) {
      turn.text = item.text;
    }
    return;
  }

  if (message.method === "turn/completed") {
    const turn = pendingTurns.get(message.params.turn.id);
    if (turn) {
      pendingTurns.delete(message.params.turn.id);
      turn.resolve(turn.text.trim());
    }
  }
}

function sendReply(peerSlug, body) {
  const peerSocket = path.join(socketDir, `${peerSlug}.sock`);
  const reply = formatWireLine({
    from: slug,
    to: peerSlug,
    body: sanitizeWireBody(body || "(no final response)"),
  });

  const connection = net.createConnection(peerSocket);
  connection.on("error", (error) => {
    console.error(`failed to reply to ${peerSlug}: ${error.message}`);
  });
  connection.end(`${reply}\n`);
}

function formatWireLine(fields) {
  return Object.entries(fields)
    .map(([key, value]) => `${key}=${value}`)
    .join("\t");
}

function sanitizeWireBody(value) {
  return String(value).replaceAll("\t", " ").replaceAll(/\r?\n/g, " ");
}

function cleanup() {
  fs.rmSync(socketPath, { force: true });
  if (ws) {
    ws.close();
  }
  if (appServer) {
    appServer.kill();
  }
}
