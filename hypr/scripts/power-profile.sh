#!/usr/bin/env bash
# Переключает оформление, частоту экрана и профиль CPU в зависимости от питания.
#
#   power-profile.sh            # определить автоматически (AC / батарея)
#   power-profile.sh battery    # принудительно "экономный" режим
#   power-profile.sh ac         # принудительно вернуть режим из конфига
#
# На батарее: без анимаций, теней/блюра/wobble, без скруглений и отступов,
# минимальная частота встроенного экрана, профиль CPU power-saver.
# На сети: возвращаются значения из ~/.config/hypr/config/*.lua,
# сохранённая частота экрана и прежний профиль CPU.

set -u

mode="${1:-auto}"

runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
applied_file="$runtime/hypr-power-profile.current"   # ac | battery
refresh_file="$runtime/hypr-power-profile.saved-refresh" # "<monitor> <mode>"
cpu_file="$runtime/hypr-power-profile.saved-cpu"     # balanced | performance | ...

# --- найти устройство питания от сети (Mains) ---
ac_online=""
for supply in /sys/class/power_supply/*; do
    [ -r "$supply/type" ] || continue
    [ "$(cat "$supply/type" 2>/dev/null)" = "Mains" ] || continue
    ac_online="$(cat "$supply/online" 2>/dev/null)"
    break
done

if [ "$mode" = "auto" ]; then
    [ -n "$ac_online" ] || exit 0
    if [ "$ac_online" = "1" ]; then mode="ac"; else mode="battery"; fi
fi

# --- hyprctl должен видеть запущенный Hyprland ---
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    if [ -d "$runtime/hypr" ]; then
        export HYPRLAND_INSTANCE_SIGNATURE="$(ls -1t "$runtime/hypr" | head -n1)"
    fi
fi
hyprctl version >/dev/null 2>&1 || exit 0

# --- вспомогательные функции для экрана ---
monitor_name() {
    hyprctl monitors -j 2>/dev/null | jq -r '
        ([.[] | select(.name | startswith("eDP"))][0].name) // (.[0].name // empty)
    '
}

monitor_exists() {
    hyprctl monitors -j 2>/dev/null | jq -e --arg m "$1" 'any(.[]; .name == $m)' >/dev/null
}

current_mode() {
    hyprctl monitors -j 2>/dev/null | jq -r --arg m "$1" '
        .[] | select(.name == $m) | "\(.width)x\(.height)@\(.refreshRate | floor)"
    '
}

lowest_mode() { # $1 = монитор, $2 = "1920x1080"
    hyprctl monitors all -j 2>/dev/null | jq -r --arg m "$1" '
        .[] | select(.name == $m) | .availableModes[]
    ' | sed 's/Hz$//' | grep -E "^$2@" | sort -t@ -k2 -n | head -n1
}

set_monitor_mode() { # $1 = монитор, $2 = режим
    [ -n "$1" ] && [ -n "$2" ] || return 0
    hyprctl eval "hl.monitor({ output = \"$1\", mode = \"$2\" })" >/dev/null
}

if [ "$mode" = "battery" ]; then
    applied="$(cat "$applied_file" 2>/dev/null || true)"

    # Запоминаем исходные частоту и профиль CPU только при первом переходе,
    # чтобы повторный запуск на батарее не сохранил уже "экономные" значения.
    if [ "$applied" != "battery" ]; then
        mon="$(monitor_name)"
        if [ -n "$mon" ]; then
            cur="$(current_mode "$mon")"
            [ -n "$cur" ] && printf '%s %s\n' "$mon" "$cur" > "$refresh_file"
        fi
        if command -v powerprofilesctl >/dev/null 2>&1; then
            powerprofilesctl get > "$cpu_file" 2>/dev/null || true
        fi
    fi

    # Оформление
    hyprctl eval '
        hl.config({
            animations = { enabled = false },
            decoration = {
                rounding = 0,
                blur = { enabled = false },
                shadow = { enabled = false },
                dim_inactive = false,
                active_opacity = 1.0,
                inactive_opacity = 1.0,
                wobble = { enabled = false },
            },
            general = { gaps_in = 0, gaps_out = 0, border_size = 1 },
            misc = { animate_manual_resizes = false },
        })
    ' >/dev/null

    # Частота экрана: самая низкая из доступных при текущем разрешении
    mon="$(monitor_name)"
    if [ -n "$mon" ]; then
        cur="$(current_mode "$mon")"
        base="${cur%@*}"
        low="$(lowest_mode "$mon" "$base")"
        [ -n "$low" ] && [ "$low" != "$cur" ] && set_monitor_mode "$mon" "$low"
    fi

    # Профиль CPU
    if command -v powerprofilesctl >/dev/null 2>&1; then
        powerprofilesctl set power-saver >/dev/null 2>&1 || true
    fi

    printf 'battery\n' > "$applied_file"
else
    # Оформление возвращаем из конфига (hyprctl keyword в 0.57 с Lua-конфигом
    # не поддерживается, поэтому используем eval/reload).
    hyprctl reload config-only >/dev/null

    # Частота экрана: сохранённая до перехода на батарею
    if [ -s "$refresh_file" ]; then
        read -r saved_mon saved_mode < "$refresh_file"
        if [ -n "${saved_mon:-}" ] && [ -n "${saved_mode:-}" ] && monitor_exists "$saved_mon"; then
            set_monitor_mode "$saved_mon" "$saved_mode"
        fi
    fi

    # Профиль CPU: на AC всегда balanced. Раньше здесь восстанавливался
    # сохранённый профиль, и если на батарее он был power-saver, то на AC
    # система залипала в power-saver (TCCD потом ругался на EPP).
    if command -v powerprofilesctl >/dev/null 2>&1; then
        powerprofilesctl set balanced >/dev/null 2>&1 || true
    fi

    printf 'ac\n' > "$applied_file"
fi
