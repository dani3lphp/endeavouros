#!/usr/bin/env bash
set -euo pipefail

# Kill existing polybar instances
killall -q polybar || true

# Wait for the processes to shut down
while pgrep -x polybar >/dev/null; do 
    sleep 0.5
done

# Wait for i3 to fully initialize
sleep 1

# Launch Polybar: main bar (with tray) on primary, secondary bar (no tray) on others
if type "xrandr" > /dev/null 2>&1; then
    # Get primary monitor (fallback to first connected if no primary set)
    PRIMARY=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
    if [[ -z "$PRIMARY" ]]; then
        PRIMARY=$(xrandr --query | grep " connected" | head -n1 | cut -d" " -f1)
    fi
    
    # Launch bars for each monitor
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        if [[ "$m" == "$PRIMARY" ]]; then
            # Primary monitor gets the tray
            MONITOR=$m polybar --reload main --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar-$m.log & disown
        else
            # Secondary monitors get no tray
            MONITOR=$m polybar --reload secondary --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar-$m.log & disown
        fi
    done
else
    # No xrandr: single monitor with tray
    polybar --reload main --config="$HOME/.config/polybar/config.ini" 2>&1 | tee -a /tmp/polybar.log & disown
fi

echo "Polybar launched..."

# Wait for tray manager to be ready (poll for _NET_SYSTEM_TRAY_S0 selection)
wait_for_tray() {
    local max_wait=10
    local waited=0
    while [[ $waited -lt $max_wait ]]; do
        if xprop -root _NET_SYSTEM_TRAY_S0 2>/dev/null | grep -q "window id"; then
            return 0
        fi
        sleep 0.5
        waited=$((waited + 1))
    done
    return 1
}

if wait_for_tray; then
    echo "System tray ready, launching tray apps..."
    # Launch tray applications after tray is confirmed ready
    nm-applet &
    volumeicon &
    blueman-applet &
else
    echo "Warning: Tray manager not detected after 5s, launching apps anyway..."
    nm-applet &
    volumeicon &
    blueman-applet &
fi
