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

**WARNING:** The bespoke `cf-cli` tool at `~/repos/cf-cli` has a bug in its authentication handling and argument parsing (`config set`). Do not use it.

**Use direct `curl` commands instead.**

- **Account ID:** `6d2cc54a1421057aa2052c7eb1d2ad20`
- **List Tunnels:**
  ```bash
  curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/6d2cc54a1421057aa2052c7eb1d2ad20/cfd_tunnel" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    | jq
  ```

Add whatever helps you do your job. This is your cheat sheet.
