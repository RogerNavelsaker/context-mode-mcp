#!/usr/bin/env bun

const cliEntryUrl = await import.meta.resolve("context-mode/cli");
const serverEntryUrl = new URL("server.bundle.mjs", cliEntryUrl).href;

await import(serverEntryUrl);
