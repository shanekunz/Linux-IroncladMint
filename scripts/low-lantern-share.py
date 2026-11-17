#!/usr/bin/env python3
"""Start/inspect/stop an authenticated temporary Collie Cloudflare tunnel."""

import argparse
import base64
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import time
import urllib.request
import urllib.error


HOME = Path.home()
STATE = HOME / ".local/state/low-lantern-share"
CONFIG = STATE / "collie"
UNITS = {name: f"low-lantern-{name}.service" for name in ("herdr", "proxy", "tunnel")}


def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, **kwargs)


def tool(name):
    found = shutil.which(name)
    if not found:
        found = run("mise", "which", name, capture_output=True).stdout.strip()
    return found


def active(name):
    return subprocess.run(
        ["systemctl", "--user", "is-active", "--quiet", UNITS[name]]
    ).returncode == 0


def service(name, *command, cwd=None):
    if active(name):
        return
    run(
        "systemd-run", "--user", f"--unit={UNITS[name]}", "--collect",
        f"--property=Restart={'no' if name == 'tunnel' else 'on-failure'}", "--property=RestartSec=3",
        f"--working-directory={cwd or STATE}",
        f"--setenv=PATH={os.environ['PATH']}", "--", *command,
    )


def collie(*args):
    env = dict(os.environ, HERDR_PLUGIN_CONFIG_DIR=str(CONFIG))
    run(tool("collie"), *args, env=env)


def private_file(path, content):
    # All parents live under the private state directory.
    with open(path, "w", opener=lambda p, flags: os.open(p, flags, 0o600)) as out:
        out.write(content)
    path.chmod(0o600)


def show():
    for name in UNITS:
        print(f"{name}: {'running' if active(name) else 'stopped'}")
    if (STATE / "access.json").exists():
        access = json.loads((STATE / "access.json").read_text())
        print(f"URL: {access.get('url', '(starting)')}")
        print(f"Username: {access['username']}\nPassword: {access['password']}")
        print(f"Private connection details: {STATE / 'access.json'}")


def start(repo):
    if not repo.is_dir():
        raise SystemExit(f"Clone low-lantern to {repo} first, or pass --repo PATH.")
    STATE.mkdir(parents=True, exist_ok=True, mode=0o700)
    STATE.chmod(0o700)
    CONFIG.mkdir(exist_ok=True, mode=0o700)
    existing = run(
        "systemctl", "--user", "show", "collie.service", "--property=Environment",
        "--value", capture_output=True,
    ).stdout.strip()
    if existing and f"HERDR_PLUGIN_CONFIG_DIR={CONFIG}" not in existing:
        raise SystemExit("An unrelated collie.service exists; inspect it before replacing its configuration.")
    herdr = tool("herdr")
    caddy = tool("caddy")
    cloudflared = tool("cloudflared")
    # Explicit PATH also works for a systemd manager started before mise was installed.
    os.environ["PATH"] = os.pathsep.join([
        str(HOME / ".local/bin"), str(HOME / ".local/share/mise/shims"),
        str(Path(herdr).parent), os.environ["PATH"],
    ])
    if not active("herdr"):
        socket = HOME / ".config/herdr/herdr.sock"
        if socket.exists():
            raise SystemExit("An existing Herdr socket is present; inspect it before starting this service.")
    service("herdr", herdr, "server", cwd=repo)
    for _ in range(30):
        result = subprocess.run([herdr, "status"], capture_output=True)
        if result.returncode == 0:
            break
        time.sleep(1)
    else:
        raise SystemExit("Herdr did not become ready; inspect journalctl --user -u low-lantern-herdr.")

    access_file = STATE / "access.json"
    access = json.loads(access_file.read_text()) if access_file.exists() else {
        "username": "friend", "password": secrets.token_urlsafe(24),
    }
    private_file(access_file, json.dumps(access, indent=2) + "\n")
    hashed = run(caddy, "hash-password", input=access["password"] + "\n", capture_output=True).stdout.strip()
    private_file(STATE / "Caddyfile", f"""{{
    admin off
    auto_https off
}}
http://:8788 {{
    bind 127.0.0.1
    basic_auth {{
        {access['username']} {hashed}
    }}
    reverse_proxy 127.0.0.1:8787 {{
        header_up X-Collie-Device shared-friend
        header_up -Tailscale-User-Login
        header_up -Authorization
    }}
}}
""")
    run(caddy, "validate", "--config", str(STATE / "Caddyfile"), "--adapter", "caddyfile")
    service("proxy", caddy, "run", "--config", str(STATE / "Caddyfile"), "--adapter", "caddyfile")
    # Ignore any unrelated named-tunnel ingress rules in ~/.cloudflared/config.yml.
    service("tunnel", cloudflared, "tunnel", "--config", "/dev/null", "--url", "http://127.0.0.1:8788", "--no-autoupdate")
    for _ in range(60):
        since = run(
            "systemctl", "--user", "show", UNITS["tunnel"],
            "--property=ActiveEnterTimestamp", "--value", capture_output=True,
        ).stdout.strip()
        logs = run(
            "journalctl", "--user", "-u", UNITS["tunnel"], "--since", since,
            "--no-pager", "-o", "cat", capture_output=True,
        ).stdout
        urls = re.findall(r"https://[a-z0-9-]+\.trycloudflare\.com", logs)
        if urls:
            access["url"] = urls[-1]
            break
        time.sleep(1)
    else:
        raise SystemExit("Tunnel URL not available; inspect journalctl --user -u low-lantern-tunnel.")
    private_file(access_file, json.dumps(access, indent=2) + "\n")
    host = access["url"].removeprefix("https://")
    config = f"""COLLIE_MUX=herdr
HERDR_SOCKET_PATH={HOME}/.config/herdr/herdr.sock
COLLIE_MULTI_SESSION=off
COLLIE_HOST=127.0.0.1
COLLIE_PORT=8787
COLLIE_SKIP_SERVE=1
COLLIE_PUBLIC_HOSTS={host}
COLLIE_ALLOWED_ORIGINS={access['url']}
COLLIE_PUBLIC_URL={access['url']}
COLLIE_DEVICE_HEADER=X-Collie-Device
COLLIE_DEVICE_ALLOWLIST=shared-friend
"""
    changed = not (CONFIG / ".env").exists() or (CONFIG / ".env").read_text() != config
    private_file(CONFIG / ".env", config)
    collie_active = subprocess.run(
        ["systemctl", "--user", "is-active", "--quiet", "collie.service"]
    ).returncode == 0
    if changed or not collie_active:
        collie("restart")
    for _ in range(30):
        try:
            with urllib.request.urlopen("http://127.0.0.1:8787/api/snapshot", timeout=3) as response:
                if response.status == 200:
                    break
        except OSError:
            pass
        time.sleep(1)
    else:
        raise SystemExit("Collie is not ready; check collie.service logs.")
    verify_public(access)
    show()


def verify_public(access):
    auth = base64.b64encode(f"{access['username']}:{access['password']}".encode()).decode()
    last_error = None
    for _ in range(12):
        try:
            for path in ("/", "/api/snapshot"):
                try:
                    with urllib.request.urlopen(access["url"] + path, timeout=10):
                        raise SystemExit("Public endpoint unexpectedly allowed an unauthenticated request.")
                except urllib.error.HTTPError as error:
                    if error.code != 401:
                        raise
                request = urllib.request.Request(
                    access["url"] + path, headers={"Authorization": f"Basic {auth}"},
                )
                with urllib.request.urlopen(request, timeout=10) as response:
                    if path == "/api/snapshot":
                        snapshot = json.load(response)
                        if snapshot.get("bridge") != "connected" or not snapshot.get("device", {}).get("authorized"):
                            raise OSError("Collie has no connected, authorized Herdr backend yet.")
            print("Verified public login, protected API, and connected Herdr backend.")
            return
        except OSError as error:
            last_error = error
            time.sleep(2)
    raise SystemExit(f"Public verification failed: {last_error}")


def stop():
    for name in ("tunnel", "proxy"):
        # Stop activating/restarting units too, not only ones currently active.
        subprocess.run(
            ["systemctl", "--user", "stop", UNITS[name]],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["start", "status", "stop"])
    parser.add_argument("--repo", type=Path, default=HOME / "projects/low-lantern")
    args = parser.parse_args()
    if args.action == "start":
        try:
            start(args.repo.resolve())
        except (Exception, SystemExit, KeyboardInterrupt):
            stop()
            raise
    elif args.action == "stop":
        stop()
        print("Public access closed. Herdr and its agent sessions remain running locally.")
    else:
        show()
