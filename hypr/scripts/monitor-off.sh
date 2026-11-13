#!/usr/bin/env bash
# Turn all monitors off (DPMS) after a short delay.
# The delay lets the triggering key press/release finish, otherwise
# misc:key_press_enables_dpms immediately wakes the display again (visible blink).
sleep 0.8
hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'
