# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

### Cloudflare (`cf-cli`)

The bespoke `cf-cli` tool at `~/repos/cf-cli` is the primary method for interacting with Cloudflare.

**Authentication:**
The tool uses the `CLOUDFLARE_API_TOKEN` and `CF_ACCOUNT_ID` environment variables, which are configured in `~/.openclaw/.env` and loaded by the gateway.

- **Account ID:** `6d2cc54a1421057aa2052c7eb1d2ad20`

**Usage:**
All commands should be run via the source file using `bun`.

- **List Tunnels:**
  ```bash
  ~/.bun/bin/bun run ~/repos/cf-cli/src/index.ts tunnels list
  ```

Add whatever helps you do your job. This is your cheat sheet.
