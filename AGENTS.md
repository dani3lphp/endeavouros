# AGENTS.md

## Project overview
- **Purpose**: Personal **EndeavourOS (Arch Linux) post-install** setup + dotfiles repository
- **Target use case**: Gaming + development laptop workflow
- **Primary language**: Bash (825 lines in main `setup` script)
- **Configuration files**: i3, fish, kitty, fastfetch, GTK3, Bluetooth (bluez)
- **Package managers**: pacman (official repos) + yay (AUR helper)
- **Privilege level**: Requires `sudo` for system-level changes (Bluetooth config, systemd services, driver installation)

## Quick start
1. Read `README.md` for hardware assumptions and cautions
2. Run: `chmod +x setup && ./setup`
3. Navigate interactive menu (uses `sudo` and package managers)

## Core files structure

### Main automation script
- **`setup`** (825 lines, Bash)
  - Interactive menu-driven installer/configurer
  - 40+ functions organized into logical sections
  - Main entry point for all setup operations
  - Handles: package installation, dotfiles, NVIDIA, Bluetooth, performance tweaks

### Configuration directories (dotfiles)
- **`i3config/`** - i3 window manager
  - `config` - i3 window manager configuration
  - `polybar/` - Polybar configuration (status bar)
  - `scripts/battery` - battery indicator script (Bash, reads `/sys/class/power_supply`)
  - `scripts/volume-click` - volume display script (Bash, uses `pactl`)
  - `scripts/temperature` - CPU temp script (Bash, reads `/sys` or uses `sensors`)
- **`fish/`** - interactive shell
  - `config.fish` - shell configuration (aliases, runs fastfetch)
- **`kitty/`** - terminal emulator
  - `kitty.conf` - main terminal configuration
  - `current-theme.conf`, `nord.conf` - color themes
- **`fastfetch/`** - system info tool
  - `config.jsonc` - JSON with comments configuration
- **`gtk-3.0/`** - GTK theme settings
  - `settings.ini`, `gtk.css`, `bookmarks`

### Documentation
- **`README.md`** - User-facing setup guide and troubleshooting
- **`AGENTS.md`** - This file (developer guide)
- **`IMPROVEMENTS.md`** - Change log / improvement tracking

### Legacy/deprecated
- `endeavouros-setup.sh` - Deprecated (redirects to `./setup`)
- `setup-dotfiles.sh` - Deprecated (redirects to `./setup`)

## Installation paths (XDG Base Directory)
All user configs install to `~/.config/`:
- i3 → `~/.config/i3/`
- fish → `~/.config/fish/config.fish`
- kitty → `~/.config/kitty/`
- fastfetch → `~/.config/fastfetch/config.jsonc`
- GTK3 → `~/.config/gtk-3.0/`

System-level configs (require `sudo`):
- Bluetooth → `/etc/bluetooth/main.conf`
- Performance → `/etc/systemd/system/*.service`

## Setup script architecture

### Key functions (40+ total)
**UI/Utilities**:
- `info()`, `ok()`, `warn()`, `err()` - Colored output helpers
- `ask_yn()` - Yes/no prompts with `--yes` flag support
- `pause()` - "Press Enter to continue" helper
- `clear_screen()` - Terminal clearing

**Package management**:
- `pacman_install_needed()` - Install official packages with `--needed` flag
- `ensure_yay()` - Auto-install yay AUR helper if missing
- `yay_install_needed()` - Install AUR packages

**Backup system** (unified session-based):
- `backup_path_if_exists()` - Backup system files (with sudo)
- `backup_path_if_exists_user()` - Backup user files
- Backups stored in: `~/.config/endeavouros-setup/backups/session_YYYYMMDD_HHMMSS/`
- Single backup per session (no duplicate `.bak` files)

**Dotfiles installation**:
- `setup_i3()`, `setup_fish()`, `setup_kitty()`, `setup_fastfetch()`, `setup_gtk3()`
- `setup_all_dotfiles()` - Orchestrates all dotfile installations
- `copy_file_with_backup()` - Backup + copy single file
- `copy_dir_contents_with_backup()` - Backup + copy directory contents

**NVIDIA drivers**:
- `install_nvidia_drivers_menu()` - Interactive driver selection
- `nvidia_driver_installed()` - Detection via `nvidia-smi` + package checks
- `ensure_envycontrol_installed()` - Install GPU switching tool
- `envycontrol_menu()` - Switch between NVIDIA/Hybrid/Integrated modes

**Bluetooth** (compact TUI):
- `bluetooth_turn_on()` - Enable service, set AutoEnable=true, configure agent
- `bluetooth_is_configured()` - Check if service is enabled and running
- `bluetooth_scan_devices()` - 10-second scan with device discovery
- `bluetooth_pair_device()` - Auto-pair with confirmation handling (sends "yes" automatically)
- `bluetooth_connect_device()` - Connect to paired device
- `bluetooth_disconnect_device()` - Disconnect active device
- `bluetooth_remove_device()` - Remove/unpair device
- `bluetooth_select_device_from_list()` - Numbered device selection (no manual MAC typing)
- `bluetooth_menu()` - Main Bluetooth TUI (7 options, compact design)

**Performance tweaks** (hardware-specific):
- `setup_performance()` - BD PROCHOT disable, CPU governor, turbo settings
- Creates systemd services for persistence

**Menu system**:
- `main_menu()` - Top-level menu (9 options)
- `run_complete_setup()` - Automated full setup workflow

## Essential packages installed
**Official repos**:
- i3 ecosystem: `polybar`, `pavucontrol`, `acpi`, `lm_sensors`
- Shell/terminal: `fish`, `kitty`
- Development: `nodejs`, `npm`, `pnpm`
- Tools: `msr-tools`, `cpupower`, `fastfetch`, `flameshot`, `chromium`
- Fonts: `ttf-jetbrains-mono-nerd`

**AUR packages**:
- `vscodium-bin` - VSCode alternative
- `envycontrol` - GPU mode switching
- `nvidia-inst` - NVIDIA driver auto-detection (optional)

## Bash scripting conventions

### Safety features
- `set -euo pipefail` - Exit on error, undefined variables, pipe failures
- Unified backup system prevents file loss
- `--needed` flag for idempotent package installation
- Explicit `sudo` usage (never runs entire script as root)
- Dry-run mode: `./setup --dry-run`
- Non-interactive mode: `./setup --yes`

### Code style
- Functions use snake_case: `bluetooth_pair_device()`
- Clear function naming (verb_noun pattern)
- Helper functions for colored output
- Error handling: `|| { pause; return; }` (never exits script on failure)
- Comments explain hardware-specific or non-obvious behavior

### Error handling pattern
**Do**: `|| { pause; return; }` - Show error, let user continue
**Don't**: `|| die "..."` - Exit entire script (only for critical failures)

Example:
```bash
bluetooth_scan_devices || { pause; return; }
```

## Polybar configuration

### Status bar items (left to right)
1. **CPU Temperature** - `~/.config/i3/scripts/temperature`
2. **Volume** - `~/.config/i3/scripts/volume-click`
3. **Battery** - `~/.config/i3/scripts/battery`
4. **Time** - `date` (configured in `i3config/polybar/config.ini`)
5. **Date** - `date` (configured in `i3config/polybar/config.ini`)

### Polybar scripts
The Polybar config references scripts in `~/.config/i3/scripts/`.
- These scripts are included in the repo and installed by `setup_i3()`.
- If you add new modules (e.g., network), add the script and update `i3config/polybar/config.ini` accordingly.

## Bluetooth implementation details

### Design philosophy
- **Fast**: 10s scan (reduced from 15s), quick pairing (~6s)
- **Compact**: 7-option menu, minimal text
- **Automatic**: Auto-accepts pairing confirmations, auto-connects after pairing
- **Error-tolerant**: Never exits, always returns to menu

### Auto-confirmation mechanism
Pairing sends "yes" responses automatically (20 iterations @ 0.3s intervals):
```bash
for i in {1..20}; do
  sleep 0.3
  echo "yes"
done
```
This handles passkey confirmation prompts without user intervention.

### Numbered device selection
All operations use numbered selection (1, 2, 3...) instead of MAC addresses:
- User never types MAC addresses manually
- `bluetooth_select_device_from_list()` handles conversion
- Output to stderr prevents capture in `$()` command substitution

### Auto-connect behavior
- After successful pairing → automatically attempts connection
- Paired/trusted devices persist across reboots (via BlueZ)
- **Note**: Devices do NOT auto-connect on boot (requires manual connection or systemd service)

## Hardware-specific considerations

### NVIDIA drivers
- Targets laptops with NVIDIA dGPU
- Supports older cards (GTX 1050 Ti) via `nvidia-580xx-dkms`
- EnvyControl switching works same-session (no reboot required between driver install and mode switch)
- `nvidia-smi` used for runtime detection

### Performance tweaks (DANGEROUS)
- **BD PROCHOT disable**: Intel-specific, fixes throttling on certain laptops
- **NOT universally safe** - only for specific hardware
- Writes to MSR (Model-Specific Register) via `wrmsr`
- Sets CPU governor to "performance"
- User must explicitly opt-in

### Bluetooth compatibility
- Works with devices requiring passkey confirmation (e.g., Huawei FreeBuds)
- Auto-confirmation works for most consumer Bluetooth devices
- NoInputNoOutput agent mode for devices without displays

## Best practices for contributors

### Before making changes
1. **Read existing code** - Understand the function organization and naming patterns
2. **Test in VM** - Script makes system-level changes, validate safely
3. **Check backups** - Ensure backup system works for your changes
4. **Document hardware requirements** - If change is hardware-specific, note it clearly

### When adding features
- Add as dedicated function (don't expand existing functions beyond ~50 lines)
- Add menu entry in appropriate submenu
- Include in `run_complete_setup()` if part of standard workflow
- Update `AGENTS.md` and `README.md` with new feature

### When modifying Bluetooth/NVIDIA/Performance
- These sections are hardware-specific and error-prone
- Test with actual hardware when possible
- Provide clear error messages
- Never make assumptions about hardware presence

### Code organization rules
- Keep related functions together (e.g., all Bluetooth functions in one section)
- Use section comments: `############################`
- Helper functions at top, menu functions at bottom
- Main menu and `parse_args()` near end of file

### Backup system rules
- Always backup before overwriting user/system files
- Use session-based backups (single folder per run)
- Check if file exists before backing up: `[[ -e "$path" ]] || return 0`
- User files: `backup_path_if_exists_user()`
- System files: `backup_path_if_exists()` (with sudo)

### Polybar integration
- If adding scripts to `i3config/scripts/`, update the Polybar config: `i3config/polybar/config.ini`
- Use Nerd Font icons consistently
- Keep scripts executable: `chmod +x`
- Scripts should handle errors gracefully (exit 0 on failure, show "N/A")

### File format conventions
- **Bash scripts**: `set -euo pipefail`, helper functions for output
- **i3 config**: Standard i3 syntax (see i3 documentation)
- **fish config**: Fish shell syntax (not bash-compatible)
- **kitty config**: Key-value pairs, includes
- **fastfetch config**: JSON with comments (`.jsonc`)
- **GTK3**: `.ini` and CSS files

## Testing checklist

Before submitting changes:
- [ ] Bash syntax check: `bash -n setup`
- [ ] Dry-run mode works: `./setup --dry-run`
- [ ] Backup system creates proper backups
- [ ] Error handling returns to menu (doesn't exit script)
- [ ] Menu navigation works (no infinite loops)
- [ ] Package installation uses `--needed` flag
- [ ] Changes documented in `README.md` and/or `AGENTS.md`
- [ ] No hardcoded paths (use `$HOME`, `$SCRIPT_DIR` variables)
- [ ] Privileged operations use explicit `sudo`
- [ ] Functions have descriptive names

## Common pitfalls to avoid

### Don't:
- ❌ Overwrite files without backing up first
- ❌ Exit script on non-critical errors (use `|| { pause; return; }`)
- ❌ Make assumptions about hardware (NVIDIA, Bluetooth, MSR support)
- ❌ Hardcode username or home directory paths
- ❌ Run entire script with `sudo` (only specific commands need it)
- ❌ Install packages without `--needed` flag
- ❌ Use `set -e` without understanding error propagation
- ❌ Forget to update documentation when adding features
- ❌ Create `.bak` files manually (use backup functions)
- ❌ Touch files outside `~/.config/` without clear justification

### Do:
- ✅ Use helper functions (`info`, `ok`, `warn`, `err`)
- ✅ Keep functions focused and under ~50 lines
- ✅ Test in safe environment (VM or disposable install)
- ✅ Document hardware-specific behavior
- ✅ Check command availability: `command -v cmd >/dev/null 2>&1`
- ✅ Handle missing files/devices gracefully
- ✅ Provide clear error messages
- ✅ Use XDG Base Directory paths
- ✅ Follow existing naming conventions
- ✅ Keep menus compact and user-friendly

## Known issues / limitations

### Polybar scripts
- Polybar runs scripts from `~/.config/i3/scripts/` (installed by `setup_i3()`).
- Current repo-provided scripts: `temperature`, `volume-click`, `battery`.
- If you add new modules, also add the script and update `i3config/polybar/config.ini` accordingly.

### Bluetooth auto-connect
- Devices pair/trust successfully but do NOT auto-connect on boot
- Manual connection required each session (or create systemd service)

### Performance tweaks
- BD PROCHOT disable is Intel-specific
- May cause instability on untested hardware
- No validation of hardware compatibility (user assumes risk)

### NVIDIA driver selection
- Limited to 3 options (nvidia-open-dkms, nvidia-580xx-dkms, nvidia-inst)
- Manual configuration required for other scenarios
- Reboot often required after driver installation

## Development workflow

### Making changes
1. Fork/clone repository
2. Edit `setup` script or configuration files
3. Test with `./setup --dry-run`
4. Test actual installation in VM or safe environment
5. Verify backups are created correctly
6. Update documentation
7. Commit with descriptive message

### Debugging
- Use `bash -x setup` for trace output
- Check backup folder: `~/.config/endeavouros-setup/backups/session_*/`
- Test individual functions in interactive shell
- Use dry-run mode to preview actions

### Release process
- Update `IMPROVEMENTS.md` with changes
- Test complete setup workflow: `./setup` → option 8
- Verify all menu options work
- Check README.md accuracy
- Tag release if significant changes

---

**Note**: This is a personal setup repository. Contributions are welcome but should align with the core philosophy: safe, interactive, well-documented automation for EndeavourOS i3 setups.
