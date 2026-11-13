-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")
    hl.exec_cmd("[workspace 1] thorium-browser-avx2")
    hl.exec_cmd("[workspace 4 silent] opencode-desktop")
    hl.exec_cmd("[workspace 5 silent] steam")
    hl.exec_cmd("[workspace special silent] /home/safeidv/.local/bin/exdesktop", {move={30,167}, size ={1116,838}, float=true})
    hl.exec_cmd("[workspace special silent] spotify", {move={286,45}, size={1447,877}, float=true})
    -- Chatterino+ запускаем через обёртку: она ждёт готовности PipeWire,
    -- иначе miniaudio-поток аварийно завершает процесс при старте сессии.
    hl.exec_cmd("[workspace special silent] /home/safeidv/.config/hypr/scripts/chatterino-launch.sh", {move={1358,45}, size={542,1021}, float=true})
end)
