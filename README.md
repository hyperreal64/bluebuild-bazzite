# bazzite-hyperreal

This is my custom build of UBlue OS Bazzite. It isn't anything remarkable.

## Features

* Based on `bazzite-nvidia-open:stable`.
* [Bazzite features](https://bazzite.gg)
* [Librewolf](https://librewolf.net)
* atop
* borgbackup
* borgmatic
* btrfs-assistant
* incus
* kpeoplevcard
* nmap
* Prometheus node-exporter
* xdg-desktop-portals

I'm not sure if the xdg-desktop-portals are included by upstream Bazzite, but some things like Discord Flatpak had blurriness with my HiDPI display that is no longer an issue after installing xdg-desktop-portals in `build_files/build.sh`.

Nmap is a lot easier to deal with if I just include it on the host. Otherwise I'd have to configure a rootful Distrobox, which is more cumbersome.

In contrast to the default Bazzite settings, the following systemd units are disabled by default in this build:

* bluetooth.service
* cups.service
* zfs-mount.service
* zfs-share.service
* zfs-zed.service

## Installation

```shell
sudo bootc switch --enforce-container-sigpolicy gitlab.hyperreal.coffee:5050/ublue/bluebuild-bazzite:latest
sudo systemctl reboot
```

## Notes on self-hosted gitlab-runner

### Setup Ubuntu Incus container
```shell
incus launch images:ubuntu/24.10 ubuntu-oracular -c security.privileged=true --storage incus_external
incus config set ubuntu-oracular security.nesting true
incus restart ubuntu-oracular
incus exec -t ubuntu-oracular -- sh -c "apt update"
incus exec -t ubuntu-oracular -- sh -c "mkdir /root/.ssh && chmod 700 /root/.ssh"
incus exec -t ubuntu-oracular -- sh -c "echo 'ssh-key...' >> /root/.ssh/authorized_keys"
incus exec -t ubuntu-oracular -- sh -c "apt install -y ssh"
incus exec -t ubuntu-oracular -- sh -c "systemctl enable --now ssh.service"
ssh root@<ubuntu-oracular-ip>
apt install -y build-essential wget curl
echo "gitlab-runner ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/gitlab-runner
chmod 640 /etc/sudoers.d/gitlab-runner
```

### Setup Docker

> Run these commands inside the Ubuntu Incus container. Don't need to use `sudo` as root user but whatever it's idempotent.

```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### Setup gitlab-runner

```shell
# select docker for type
gitlab-runner register --url https://gitlab.hyperreal.coffee --token <TOKEN>
systemctl restart gitlab-runner.service
chown -R gitlab-runner:gitlab-runner /etc/gitlab-runner
```

### Install cosign

```shell
LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb
```