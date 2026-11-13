#!/usr/bin/env bash
# Запуск Chatterino+ после готовности звукового сервера.
# Chatterino+ (бэкенд miniaudio) падает с SIGABRT, если PipeWire/WirePlumber
# ещё не подняли устройство вывода — это и происходит при автостарте в сессии.
# Скрипт ждёт готовности звука и перезапускает приложение, если оно всё же упало.

APPIMAGE="Leafyrino"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/chatterino-launcher.log"

log() { printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$LOG"; }
mkdir -p "$(dirname "$LOG")"

# 1. Ждём PipeWire/WirePlumber и дефолтный sink (максимум ~30 с).
for _ in $(seq 1 60); do
    if wpctl inspect @DEFAULT_AUDIO_SINK@ >/dev/null 2>&1 && pactl info >/dev/null 2>&1; then
        break
    fi
    sleep 0.5
done

# Дать WirePlumber ещё мгновение на завершение инициализации.
sleep 1

# 2. Запуск с перезапуском, если приложение упало сразу после старта.
for attempt in 1 2 3; do
    started=$(date +%s)
    "$APPIMAGE" "$@"
    rc=$?
    ran=$(( $(date +%s) - started ))
    log "запуск #$attempt: код $rc, проработал ${ran}с"
    (( rc == 0 )) && exit 0          # закрыли нормально
    (( ran > 120 )) && exit "$rc"    # упало после долгой работы — не перезапускаем
    sleep 5
done

log "не удалось запустить после 3 попыток"
exit 1
