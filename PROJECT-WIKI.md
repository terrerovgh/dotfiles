# Raspberry Pi Modular DevOps Backup & Infra - Wiki

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Initial Setup](#initial-setup)
   - [Installing Arch Linux ARM](#installing-arch-linux-arm)
   - [Basic System Configuration](#basic-system-configuration)
4. [Project Structure](#project-structure)
5. [Modules and Services](#modules-and-services)
   - [Base System](#base-system)
   - [USB Mount](#usb-mount)
   - [WiFi Hotspot](#wifi-hotspot)
   - [Transparent Proxy (Squid)](#transparent-proxy-squid)
   - [Docker + Traefik](#docker--traefik)
   - [Cloudflare Certificates](#cloudflare-certificates)
   - [Extra Services](#extra-services)
6. [Backup Automation](#backup-automation)
7. [System Restoration](#system-restoration)
8. [Security and Best Practices](#security-and-best-practices)

---

## Introduction

This project transforms a Raspberry Pi 5 running Arch Linux ARM into a modular, robust, and self-sustaining DevOps infrastructure. It is designed to be easy to maintain, modular, and secure, with a focus on automation and disaster recovery.

---

## Prerequisites

- **Hardware:** Raspberry Pi 5 with a microSD card of at least 16GB and a proper power supply.
- **Software:** Arch Linux ARM image.
- **Internet Connection:** To download packages and configurations.
- **Basic Knowledge:** Familiarity with Linux terminal and basic commands.

---

## Initial Setup

### Installing Arch Linux ARM

1. Download the Arch Linux ARM image from [archlinuxarm.org](https://archlinuxarm.org/).
2. Flash the image onto the microSD card using `dd` or tools like Balena Etcher.
3. Insert the card into the Raspberry Pi and power it on.
4. Access the system via SSH or by connecting a keyboard and monitor.

### Basic System Configuration

1. Change the `root` user password:
   ```bash
   passwd
   ```
2. Update the system:
   ```bash
   pacman -Syu
   ```
3. Set the timezone:
   ```bash
   ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
   hwclock --systohc
   ```
4. Configure language and localization:
   ```bash
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   echo "KEYMAP=us" > /etc/vconsole.conf
   locale-gen
   ```
5. Configure the network:
   ```bash
   systemctl enable dhcpcd
   systemctl start dhcpcd
   ```
6. Create a new user:
   ```bash
   useradd -m -G wheel -s /bin/bash terrerov
   passwd terrerov
   ```
7. Grant sudo permissions to the user:
   ```bash
   EDITOR=nano visudo
   # Uncomment the line: %wheel ALL=(ALL) ALL
   ```

---

## Project Structure

The project is organized into modules, each with its own folder and configuration files. Backups are stored in `/mnt/usbdata/backups/dotfiles/` and are not uploaded to GitHub.

```
dotfiles/
├── backup.sh           # Main script for modular backup and GitHub push
├── modules/            # Definition of modules and files to back up
│   ├── system/         # Base system configuration
│   ├── usb-mount/      # Automatic USB mounting
│   ├── wifi-hotspot/   # WiFi Hotspot
│   ├── docker/         # Docker and Traefik configuration
│   ├── proxy/          # Transparent proxy (Squid)
│   └── backup/         # Backup configuration
└── ...
```

---

## Modules and Services

### Base System
- Initial configuration of the operating system.
- Critical files: `/etc/hostname`, `/etc/hosts`, `/etc/fstab`.

### USB Mount
- Service for automatically mounting USB devices.
- Critical files: `/etc/systemd/system/usb-mount.service`.

### WiFi Hotspot
- Configuration of a WiFi hotspot using `create_ap`.
- Critical files: `hostapd.conf`, `dnsmasq.conf`, `iptables.rules`.

### Transparent Proxy (Squid)
- Configuration of an HTTP/HTTPS proxy with NAT redirection.
- Critical files: `/etc/squid/squid.conf`.

### Docker + Traefik
- Configuration of Docker containers and reverse proxy for subdomains.
- Critical files: `docker-compose.yml`, `traefik.yml`.

### Cloudflare Certificates
- Automation of SSL certificates with Let’s Encrypt and the Cloudflare API.
- Critical files: `cloudflare.ini`.

### Extra Services
- DNS (CoreDNS), Pi-hole, monitoring (Uptime Kuma, Netdata).

---

## Backup Automation

1. Manually execute the backup script:
   ```bash
   sudo bash /mnt/usbdata/dotfiles/backup.sh
   ```
2. Schedule the backup with cron:
   ```bash
   0 */6 * * * sudo /mnt/usbdata/dotfiles/backup.sh
   ```
3. Configure a systemd timer for better control.

---

## System Restoration

1. Copy files from `/mnt/usbdata/backups/dotfiles/<module>/` to their original locations.
2. Use the `include.txt` files in each module to identify critical files.
3. Restart necessary services:
   ```bash
   systemctl restart <service>
   ```

---

## Security and Best Practices

- Do not upload sensitive files to GitHub.
- Use SSH keys for secure authentication.
- Configure firewalls and iptables rules to protect your network.
- Regularly test restoration to ensure backup integrity.
