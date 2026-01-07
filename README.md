# EndeavourOS i3 Laptop Setup

Menu-driven post-install script + dotfiles for **EndeavourOS (Arch Linux)** running **i3 (X11)**.

This repo is aimed at a *single-user laptop workflow* (gaming + development). It is **safe-by-default** (backs up before overwriting, uses `--needed`, never runs an all-root shell).

## What's inside

- `setup` — interactive installer/configurator
- `i3config/` — i3 config + Polybar config + Polybar scripts
- `fish/` — fish shell config
- `kitty/` — kitty terminal config
- `fastfetch/` — fastfetch config
- `gtk-3.0/` — GTK3 settings
- `picom.conf` — compositor config (installed to `~/.config/picom.conf`)

## Quick start

### 1) Clone

```bash
git clone https://github.com/dani3lphp/endeavouros.git
cd endeavouros
```

### 2) Run the setup menu

```bash
chmod +x setup
./setup
```

### Useful flags

- Dry run (print actions only):
  ```bash
  ./setup --dry-run
  ```
- Non-interactive approvals (answer "yes" to prompts):
  ```bash
  ./setup --yes
  ```

## What the script changes (and where)

### Backups (important)

Before overwriting anything, the script creates a **session backup** here:

- `~/.config/endeavouros-setup/backups/session_YYYYMMDD_HHMMSS/`

### Dotfiles install paths

Everything goes into `~/.config`:

| Repo path | Installs to |
|---|---|
| `i3config/` | `~/.config/i3/` |
| `i3config/polybar/` | `~/.config/polybar/` |
| `fish/` | `~/.config/fish/` |
| `kitty/` | `~/.config/kitty/` |
| `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` |
| `gtk-3.0/` | `~/.config/gtk-3.0/` |
| `picom.conf` | `~/.config/picom.conf` |

## Setup menu guide

When you run `./setup`, you'll see a main menu similar to:

- **Update system** — `sudo pacman -Syu`
- **Install essential packages** — installs packages required by these dotfiles (plus a few common tools)
- **Install dotfiles** — copies configs into `~/.config` and makes scripts executable
- **Bluetooth menu** — scan/pair/connect/disconnect/remove devices
- **NVIDIA helpers** — installs a limited, safer set of driver options
- **EnvyControl** — switch GPU modes (`integrated` / `hybrid` / `nvidia`)
- **Performance tweaks (dangerous)** — laptop-specific tuning (opt-in)
- **Run complete setup** — recommended "do the common things" workflow

## Bluetooth (how to use)

1. Run `./setup`
2. Open **Bluetooth menu**
3. Choose **Turn on / configure** (enables `bluetooth.service` and sets AutoEnable)
4. **Scan** → pick device number → **Pair** → **Connect**

Notes:
- The pairing flow auto-accepts common confirmation prompts.
- Devices don't auto-connect on boot by default (manual connect each session).

## Polybar

- Polybar is launched by i3 via `~/.config/polybar/launch.sh`.
- The repo includes these Polybar scripts (installed into `~/.config/i3/scripts/`):
  - `temperature`
  - `volume-click`
  - `battery`

## i3 keybindings (cheatsheet)

`$mod` is **Super/Windows**.

- Terminal: `$mod+q` (kitty)
- Kill window: `$mod+c`
- Reload i3: `$mod+Shift+c`
- Restart i3: `$mod+Shift+r`
- Screenshot GUI: `$mod+Shift+s` (flameshot)

If some keybinds don't work: your i3 config may reference **personal scripts** that are not included in this repo.

## Recent improvements

### System tray fix (Jan 2026)
Fixed an issue where system tray icons (nm-applet, volumeicon, blueman-applet) wouldn't appear on first boot until workspace switching or i3 reload. The fix includes:

- **Single tray manager**: Only the primary monitor's Polybar instance manages the system tray
- **Secondary bar config**: Non-primary monitors use a tray-less Polybar configuration
- **Smart tray detection**: `launch.sh` now polls for `_NET_SYSTEM_TRAY_S0` selection before launching tray apps
- **Integrated startup**: Tray apps are launched by Polybar's launch script (not i3 config) after tray is confirmed ready

This eliminates the race condition that caused tray initialization failures.

## Troubleshooting

- **System tray icons missing**: Check `/tmp/polybar-*.log` for errors. Run `~/.config/polybar/launch.sh` manually to restart.
- **i3 changes not applied**: run `i3-msg reload` or press `$mod+Shift+c`
- **Polybar not showing**: run `~/.config/polybar/launch.sh`
- **Bluetooth**: check `systemctl status bluetooth` and try `blueman-manager`
- **GPU mode changes**: reboot is often required

## Safety notes

- The performance-tweaks section can write CPU MSR registers (hardware-specific). Only enable it if you understand the risk.
- NVIDIA driver choices are intentionally limited. For anything else, use the Arch Wiki: https://wiki.archlinux.org/title/NVIDIA
