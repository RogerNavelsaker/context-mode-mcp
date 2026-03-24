# context-mode-mcp

Bun-installable MCP server package for Context Mode.

This repo owns the generic MCP runtime surface. It does not own Pi-specific install UX or Nix packaging.

## Package Surface

- Binary: `context-mode-mcp`
- Runtime: wraps upstream `context-mode` and starts `server.bundle.mjs`
- Template config: `.mcp.json`

## Install

Global install with Bun:

```bash
bun install -g context-mode-mcp
```

Local install for development:

```bash
bun install
bun install -g .
```

Run the server on stdio:

```bash
context-mode-mcp
```

## MCP Config

Example MCP config:

```json
{
  "mcpServers": {
    "context-mode": {
      "command": "context-mode-mcp"
    }
  }
}
```

The checked-in [`.mcp.json`](/home/rona/Repositories/@runtime-intel/context-mode-mcp/.mcp.json) provides the same minimal command surface.

## Publishing

Dry-run the package publish surface:

```bash
bun run publish:dry-run
```

Build the GitHub release tarball:

```bash
bun run pack
```

Publish with Bun:

```bash
bun publish --access public
```

GitHub release source is also a supported distribution surface for the Nix packaging repo. Tagging this repo with `v<version>` will create a GitHub release, and the workflow can attach a Bun package tarball built from this repo for Nix to fetch and pin later.

## Scope

- Bun-first distribution of the MCP server
- Upstream version tracking against `mksglu/context-mode`
- Generic MCP docs and config template

## Not In Scope

- Pi package metadata
- Flox or Nix packaging
