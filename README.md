# EndeavourOS Post-Install Setup Guide

A comprehensive guide for setting up EndeavourOS after installation, optimized for gaming and development workflows.

## Table of Contents
- [Initial Setup](#initial-setup)
- [NVIDIA Driver Installation](#nvidia-driver-installation)
- [Performance Optimization](#performance-optimization)
- [System Configuration](#system-configuration)
- [Desktop Environment Setup](#desktop-environment-setup)
- [Development Tools](#development-tools)
- [Troubleshooting](#troubleshooting)

## Initial Setup

### Install Essential Packages

First, install the necessary packages for your system:

```bash
yay -S fish envycontrol msr-tools cpupower fastfetch nodejs npm pnpm vscodium-bin
```

### Update System

Make sure your system is up to date:

```bash
sudo pacman -Syu
```

## NVIDIA Driver Installation

For NVIDIA GTX 1050 Ti (or similar older cards), install the appropriate driver:

```bash
yay -S nvidia-580xx-dkms
```

### Configure GPU Management

Switch from integrated to NVIDIA GPU:

```bash
# Check current mode
sudo envycontrol -q

# Switch to NVIDIA mode
sudo envycontrol -s nvidia

# Reboot to apply changes
sudo reboot
```

## Performance Optimization

### Disable BD PROCHOT (Intel CPU Optimization)

BD PROCHOT (Bi-directional Dynamic Processor Management) can cause performance throttling. Disable it with these steps:

#### Install Required Tools
```bash
sudo pacman -S msr-tools cpupower --needed
```

#### Immediate Application
```bash
# Load MSR module
sudo modprobe msr

# Disable BD PROCHOT
sudo wrmsr -a 0x1FC 0x400

# Set performance EPP (Speed Shift)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference

# Enable Turbo
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

# Set performance governor
sudo cpupower frequency-set --governor performance

# Verify changes
watch -n 1 "cat /proc/cpuinfo | grep MHz"
```

#### Make Changes Persistent

Create systemd services to apply these settings on boot:

**Create BD PROCHOT Disable Service:**
```bash
sudo nano /etc/systemd/system/disable-bdprochot.service
```

Add the following content:
```ini
[Unit]
Description=Disable BD PROCHOT
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/fish -c '/usr/bin/modprobe msr && /usr/bin/wrmsr -a 0x1FC 0x400'

[Install]
WantedBy=multi-user.target
```

**Create Turbo and Performance Service:**
```bash
sudo nano /etc/systemd/system/turbo-enable.service
```

Add the following content:
```ini
[Unit]
Description=Enable CPU Turbo and Performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/fish -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference'
ExecStart=/usr/bin/fish -c 'echo 0 | tee /sys/devices/system/cpu/intel_pstate/no_turbo'
ExecStart=/usr/bin/cpupower frequency-set --governor performance

[Install]
WantedBy=multi-user.target
```

**Enable Services:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable disable-bdprochot.service
sudo systemctl enable turbo-enable.service
sudo systemctl enable cpupower.service
sudo systemctl start cpupower.service
```

### Systemd-boot Kernel Parameters

Add these parameters to your kernel command line in `/boot/loader/entries/endeavouros.conf`:

```
zswap.enabled=1 rhgb quiet mitigations=off
```

## Desktop Environment Setup

### i3 Window Manager Configuration

Update your i3 config with these useful keybindings:

```bash
# Edit i3 config
nano ~/.config/i3/config
```

**Recommended Keybindings:**
- `$mod+q` - Open terminal (xfce4-terminal)
- `$mod+c` - Kill window
- `$mod+b` - Open browser (Firefox)
- `$mod+e` - Open file manager (Thunar)

### Important Note: Avoid Picom

**DO NOT INSTALL PICOM** - It can cause input lag and performance issues when using NVIDIA GPU.

### Status Bar Customization

Edit your status bar (polybar, i3blocks, etc.) to your preference for a personalized look.

## Development Tools

### Install Development CLI Tools

For your development workflow, install these essential tools:

```bash
# Node.js tools are already installed via yay
# Additional tools you might want:
yay -S git docker docker-compose docker-buildx lazygit ripgrep fd fzf bat exa zoxide
```

### Shell Configuration

Since you're using Fish shell, consider installing Oh My Fish for enhanced functionality:

```bash
curl -sL https://get.oh-my.fish | fish
```

## Troubleshooting

### Common Issues

1. **Display Manager Won't Start After NVIDIA Installation**
   - Ensure you've switched to NVIDIA mode using `envycontrol`
   - Check that the correct driver is installed

2. **Performance Issues**
   - Verify BD PROCHOT is disabled
   - Check that CPU governor is set to performance
   - Ensure no compositor like Picom is running

3. **System Boot Issues**
   - Check kernel parameters in systemd-boot
   - Verify all services are enabled properly

### Useful Commands

```bash
# Check CPU frequency
watch -n 1 "cat /proc/cpuinfo | grep MHz"

# Monitor system status
fastfetch

# Check NVIDIA driver status
nvidia-smi
```

## Additional Recommendations

- Regularly update your system: `sudo pacman -Syu`
- Keep your configs backed up
- Consider setting up automatic updates with `cron` or `systemd timers`
- Install AUR helper like `yay` if not already installed

---

**Note:** This guide is tailored for a system with NVIDIA GTX 1050 Ti. Adjust driver installation accordingly for different hardware.
