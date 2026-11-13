#!/usr/bin/env bash
# Следит за сменой питания (AC <-> батарея) через udev и применяет
# power-profile.sh. Запускается systemd-юнитом hypr-power-profile.service.

set -u

script="$HOME/.config/hypr/scripts/power-profile.sh"
state_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-power-profile.last"

# --- найти устройство питания от сети (Mains) ---
ac_path=""
for supply in /sys/class/power_supply/*; do
    [ -r "$supply/type" ] || continue
    [ "$(cat "$supply/type" 2>/dev/null)" = "Mains" ] || continue
    ac_path="$supply/online"
    break
done
[ -n "$ac_path" ] || exit 0

apply() {
    local current
    current="$(cat "$ac_path" 2>/dev/null)" || return 0
    # udev присылает несколько событий на одно изменение — не дублируем работу
    [ "$(cat "$state_file" 2>/dev/null)" = "$current" ] && return 0
    printf '%s\n' "$current" > "$state_file"
    if [ "$current" = "1" ]; then
        printf 'power-profile: AC\n' >&2
    else
        printf 'power-profile: battery\n' >&2
    fi
    "$script" || true
}

apply

udevadm monitor --udev --subsystem-match=power_supply --property |
while IFS= read -r line; do
    case "$line" in
        ACTION=*) apply ;;
    esac
done
