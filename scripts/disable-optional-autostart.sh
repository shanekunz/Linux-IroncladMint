#!/bin/bash
# Keep preserved but infrequently used workloads from starting automatically.
set -e

USER_SERVICES=(
    mcporter-daemon.service
    ollama.service
    openclaw-fluid.service
    openclaw-gateway.service
    opencode-telegram-group-topics-bot.service
)

echo "Disabling optional user services..."
for service in "${USER_SERVICES[@]}"; do
    if systemctl --user cat "$service" >/dev/null 2>&1; then
        systemctl --user stop "$service"
        # systemctl disable also removes unit files deployed as Stow symlinks.
        # Remove only the enablement link so the service definition remains.
        rm -f "$HOME/.config/systemd/user/default.target.wants/$service"
    fi
done
systemctl --user daemon-reload

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    containers=()
    for container in homeassistant matter-server chartdb; do
        if docker container inspect "$container" >/dev/null 2>&1; then
            containers+=("$container")
        fi
    done

    if [ ${#containers[@]} -gt 0 ]; then
        echo "Disabling container restart policies and stopping containers..."
        docker update --restart no "${containers[@]}"
        docker stop "${containers[@]}"
    fi
fi

echo
echo "Optional user services and containers are inactive. Data was not removed."
echo "To disable Docker itself, run:"
echo "  sudo systemctl disable --now docker.service docker.socket containerd.service"
echo "See OPTIONAL_SERVICES.md for recovery and manual startup commands."
