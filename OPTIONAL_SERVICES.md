# Optional Background Services

This machine keeps several installed services available without starting them at
boot. Run `./scripts/disable-optional-autostart.sh` to restore the intended
inactive state after reinstalling or reconfiguring them.

## Startup Policy

| Workload | Default | Preserved state | Start when needed |
| --- | --- | --- | --- |
| Hermes gateway | Automatic | `~/.hermes/` and `hermes/.hermes/` | `systemctl --user start hermes-gateway.service` |
| Ollama | Manual | `~/.ollama/` and `~/.local/lib/ollama/` | `systemctl --user start ollama.service` |
| OpenCode Telegram topics bot | Manual | `~/projects/opencode-telegram-group-topics-bot/` | `systemctl --user start opencode-telegram-group-topics-bot.service` |
| OpenClaw gateway | Retired/manual | `~/.openclaw/` | See the OpenClaw section before restoring |
| OpenClaw fluid loop | Retired/manual | `~/.openclaw/workspace/culinary-commander-agents/` | Restore OpenClaw first, then enable the unit |
| mcporter daemon | Retired/manual | `~/.mcporter/` and `~/.openclaw/workspace/config/mcporter.json` | `systemctl --user start mcporter-daemon.service` |
| Home Assistant | Manual | `~/homeassistant/` | Start Docker, then `docker start homeassistant` |
| Matter server | Manual | `~/matter-server/` | Start Docker, then `docker start matter-server` |
| ChartDB | Manual | Container definition below; schema export in Culinary Commander | Start Docker, then `docker start chartdb` |

The disabled user units remain installed under
`systemd-user/.config/systemd/user/`. Disabling them removes only the startup
symlink; it does not remove the unit, application, configuration, or data.

## OpenClaw Retirement

Hermes replaces the main private-assistant path: Telegram DM, web/browser/file
tools, persistent memory, and native Sunsama and Linear MCP connections.
mcporter is not a Hermes dependency, and its configured Sunsama, Linear, and
Atlassian connections were unauthenticated when it was retired.

OpenClaw data is deliberately retained because Hermes does not automatically
import all of it:

- `~/.openclaw/workspace/MEMORY.md` and `~/.openclaw/workspace/memory/` contain
  historical memory not automatically available to Hermes.
- `~/.openclaw/agents/` contains session history for the main, family, personal,
  and CCv2 agents.
- `~/.openclaw/cron/` contains old proactive and scheduled jobs. Hermes cron is
  currently disabled.
- `~/.openclaw/workspace*/` contains persona files, tools, skills, and the CCv2
  automation workspace.
- `~/.openclaw/browser*`, `credentials/`, `tasks/`, `flows/`, and `media/`
  preserve browser state and integration history.

The current OpenClaw gateway unit is stale and points at a removed Node install.
Do not start it as-is. OpenClaw and Hermes also share a Telegram bot credential,
so stop Hermes before testing a restored OpenClaw gateway.

The retired gateway's API-key drop-ins are mode `0600`, but the keys they held
were exposed during the retirement audit. Rotate the OpenAI, Brave, and Linear
keys before any future use; do not treat the preserved copies as valid secrets.

`scripts/backup-system-state.sh` includes the full OpenClaw directory and the
important Hermes and mcporter runtime state in its encrypted archive.

## Docker Workloads

The retained containers use `restart=no`:

```bash
docker start homeassistant matter-server chartdb
docker stop homeassistant matter-server chartdb
```

Home Assistant and Matter can be recreated with
`./scripts/setup-homeassistant.sh`; the script keeps their data in the bind
mounts above and does not enable container autostart.

ChartDB was created without a persistent Docker volume. Its durable project
artifact is `~/projects/culinary-commander/docs/reference/database-schema.chartdb.json`.
If the container is ever removed, recreate it with:

```bash
docker run -d \
  --name chartdb \
  --restart no \
  -p 127.0.0.1:8081:80 \
  ghcr.io/chartdb/chartdb:latest
```

Docker is intentionally manual on this machine. Disabling Docker saves the
daemon and containerd overhead, but Hermes uses Docker for its terminal tool.
Start Docker before asking Hermes to use terminal tools:

```bash
sudo systemctl start docker.service
```

To restore Docker autostart:

```bash
sudo systemctl enable --now containerd.service docker.socket docker.service
```

## Other Installed Services

- Touchégg is Linux Mint's touchpad gesture daemon. It is currently left
  enabled; it used about 15 MiB during the audit.
- `openvpn.service` is an empty compatibility/umbrella unit. There are no
  client or server profiles under `/etc/openvpn/`, and the unit has no resident
  process.
- Native CUPS and the CUPS snap are both active. The snap is connected as
  Chromium's printing provider and proxies to the host print stack, so this is
  an intentional snap integration rather than two independently configured
  printer servers. Both are left unchanged.
