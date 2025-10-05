[private]
default:
    @just --list

# Setup pet distroboxes
[group('setup')]
hyperreal-setup-pet-container:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! podman container exists fedora-distrobox-42; then
      distrobox create -i ghcr.io/ublue-os/fedora-toolbox:latest -n fedora-distrobox-42
      echo "Successfully created fedora-distrobox-42"
    else
      if ugum confirm "fedora-distrobox-42 already exists. Delete and create a new one?"; then
        podman container stop --time 2 fedora-distrobox-42
        podman container rm --force fedora-distrobox-42
        distrobox create -i ghcr.io/ublue-os/fedora-toolbox:latest -n fedora-distrobox-42
        echo "Successfully create new fedora-distrobox-42"
      else
        echo "Alright, then. Ignoring."
      fi
    fi

    # setup copr repos
    copr_repos=("atim/starship" "varlad/zellij" "varlad/yazi" "ublue-os/packages")
    for x in "${copr_repos[@]}"; do
      distrobox enter --name fedora-distrobox-42 -- sudo dnf copr enable -y "$x"
    done

    # install Fedora packages
    distrobox enter --name fedora-distrobox-42 -- sudo dnf install -y $(curl -sSL https://opengist.hyperreal.coffee/hyperreal64/fedora-packages/raw/HEAD/fedora-packages.txt)

    echo ""
    echo "Pet distrobox setup complete. You may now gently caress the container's soft fluffy fur."
    echo ""
    echo 'Me: [cutesy voice] "My witt-o containery. So cute. Such a good container."'
    echo 'Rubber duck: "Easy there, Lenny."'

# Install local justfile
[group('install')]
install-local-justfile:
    #!/usr/bin/env bash
    rm -fv "${HOME}/.justfile"
    wget https://opengist.hyperreal.coffee/hyperreal/justfile/raw/HEAD/justfile -O "${HOME}/.justfile"
