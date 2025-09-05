# bluebuild-bazzite

This is my custom build of UBlue OS Bazzite. It isn't anything remarkable.

## Features

* Based on `bazzite-nvidia-open:stable`.
* [Bazzite features](https://bazzite.gg)
* atop
* borgbackup
* borgmatic
* btrfs-assistant
* incus
* nmap
* Prometheus node-exporter
* xdg-desktop-portals

I'm not sure if the xdg-desktop-portals are included by upstream Bazzite, but some things like Discord Flatpak had blurriness with my HiDPI display that is no longer an issue after installing xdg-desktop-portals in `recipes/recipe.yml`.

Nmap is a lot easier to deal with if I just include it on the host. Otherwise I'd have to configure a rootful Distrobox, which is more cumbersome.

In contrast to the default Bazzite settings, the following systemd units are disabled by default in this build:

* bluetooth.service
* cups.service
* zfs-mount.service
* zfs-share.service
* zfs-zed.service

## Installation

```shell
sudo bootc switch --enforce-container-sigpolicy ghcr.io/hyperreal64/bluebuild-bazzite:latest
sudo systemctl reboot
```