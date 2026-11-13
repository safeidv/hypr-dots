#!/usr/bin/env bash
# Следит за DPMS: когда монитор включается после выключения, заново
# применяет power-profile.sh (экономный режим на батарее / обычный на сети).
# Запускается systemd-юнитом hypr-monitor-power.service.

set -u

script="$HOME/.config/hypr/scripts/power-profile.sh"
runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# hyprctl должен видеть запущенный Hyprland
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "$runtime/hypr" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE="$(ls -1t "$runtime/hypr" | head -n1)"
fi

prev=""
while true; do
    # "on", если хотя бы один монитор не в DPMS off
    status="$(hyprctl monitors -j 2>/dev/null | jq -r 'if any(.[]; .dpmsStatus) then "on" else "off" end' 2>/dev/null)"

    if [ -n "$status" ]; then
        # Срабатываем только на переход off -> on
        if [ "$prev" = "off" ] && [ "$status" = "on" ]; then
            printf 'monitor on -> power-profile\n' >&2
            "$script" auto || true
        fi
        prev="$status"
    fi

    sleep 1
done
