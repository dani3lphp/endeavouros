# EndeavourOS Post-Install Setup Guide

A comprehensive guide for setting up EndeavourOS after installation, optimized for gaming and development workflows.

## Table of Contents
- [Initial Setup](#initial-setup)
- [NVIDIA Driver Installation](#nvidia-driver-installation)
- [Performance Optimization](#performance-optimization)
- [System Configuration](#system-configuration)
- [Desktop Environment Setup](#desktop-environment-setup)
- [Automated Setup Script](#automated-setup-script)
- [Development Tools](#development-tools)
- [Troubleshooting](#troubleshooting)

## Initial Setup

### Update System

Make sure your system is up to date:

```bash
sudo pacman -Syu
```

### Install Essential Packages

First, install the necessary packages for your system (these are my personal preferred packages):

```bash
sudo pacman -S fish envycontrol msr-tools cpupower fastfetch nodejs npm pnpm vscodium-bin flameshot obs-studio
```

## NVIDIA Driver Installation

First, check if linux headers are already installed:

```bash
yay -S linux-headers --needed
```

For NVIDIA GTX 1050 Ti (or similar older cards), install the appropriate driver:

```bash
yay -S nvidia-580xx-dkms
```

For different cards, newer or older, please consult the [arch wiki page](https://wiki.archlinux.org/title/NVIDIA) or the official [EndeavourOS NVIDIA Drivers wiki](https://discovery.endeavouros.com/nvidia/new-nvidia-driver-installer-nvidia-inst/2022/03/)

### Configure GPU Management

Switch from integrated to NVIDIA GPU:

```bash
# Check current mode
sudo envycontrol -q

# Switch to NVIDIA mode
sudo envycontrol -s nvidia --force-comp

# Reboot to apply changes
sudo reboot
```

## Performance Optimization

### Disable BD PROCHOT (Intel CPU Optimization)

BD PROCHOT (Bi-directional Dynamic Processor Management) can cause performance throttling. For my specific laptop it does. If you encounter the same throttling problem, you can follow the steps below to fix the automatic BD PROCHOT limitations. Disable it with these steps:

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

Add these parameters to your kernel command line in `/efi/loader/entries/yourownconfigname.conf`:

```
zswap.enabled=1 rhgb quiet mitigations=off
```

## Desktop Environment Setup

### i3 Window Manager Configuration

Configure i3 with the provided configuration files. You can use the automated setup script to copy all configuration files to their appropriate locations (see the [Automated Setup Script](#automated-setup-script) section below).

**ONLY DO THIS IF YOU WANT THE SAME CONFIG AS MINE**

### Important Note: Avoid Picom

**DO NOT INSTALL PICOM** - It can cause input lag and performance issues when using NVIDIA GPU if you have an AC power adapter like mine that is either faulty or has lower wattage and doesn't output enough energy for all laptop specs.

For example, I have a 120W adapter and it is not enough to power the full laptop, so therefore the BD PROCHOT automatic limitations.

**PICOM SHOULD WORK FINE IF YOUR LAPTOP/PC DOESN'T HAVE ANY POWER LIMITATIONS** - So, please consult their official wiki on how to set it up properly if you want to.

## Automated Setup Script

This repository includes a setup script that automates the configuration process by copying the provided configuration files to their appropriate locations in your home directory.

### What the Script Does

The `setup-dotfiles.sh` script:

- Copies i3 configuration files (`config`, `i3blocks.conf`) to `~/.config/i3/`
- Copies the volume-click script to `~/.config/i3/scripts/` and makes it executable
- Copies the fish configuration file to `~/.config/fish/config.fish`
- Creates necessary directories if they don't exist

### How to Use the Setup Script

1. Make the script executable:
   ```bash
   chmod +x setup-dotfiles.sh
   ```

2. Run the script:
   ```bash
   ./setup-dotfiles.sh
   ```

3. The script will copy all configuration files and display status messages as it works.

4. After running the script, you may need to:
   - Restart your shell or run `exec fish` for fish changes to take effect
   - Reload the i3 configuration with Mod+Shift+R or restart i3

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

