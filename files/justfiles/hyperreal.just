[private]
default:
    @just --list

# Copy GAME screenshots
[group('gaming')]
copy-screenshots:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh

    GAME=$(ugum choose eso starfield bg3)
    case "$GAME" in
        "eso")
          find "${HOME}/.steam/steam/steamapps/compatdata/306130/pfx/drive_c/users/steamuser/Documents/Elder Scrolls Online/live/Screenshots" \
            -maxdepth 1 \
            -mindepth 1 \
            -exec cp -fv {} "${HOME}/nextcloud/pictures/eso_screenshots" \;
          ;;
        "starfield")
          find "${HOME}/.steam/steam/steamapps/compatdata/1716740/pfx/drive_c/users/steamuser/My Documents/My Games/Starfield/Data/Textures/Photos" \
            -maxdepth 1 \
            -mindepth 1 \
            -not -name "*-thumbnail.png" \
            -exec cp -fv {} "${HOME}/nextcloud/pictures/starfield_screenshots" \;
          ;;
        "bg3")
          find "${HOME}/games/gog/baldurs-gate-3/drive_c/users/steamuser/My Documents/Larian Studios/Baldur's Gate 3/Screenshots" \
            -maxdepth 1 \
            -mindepth 1 \
            -exec cp -fv {} "${HOME}/nextcloud/pictures/bg3_screenshots" \;
          ;;
        *)
          echo "Unknown game"
          ;;
    esac

# Install Go tools
[group('install')]
hyperreal-install-go-tools:
    #!/usr/bin/env bash
    go_tools=(
      "golang.org/x/tools/gopls@latest"
      "github.com/fatih/gomodifytags@latest"
      "github.com/cweill/gotests/...@latest"
      "github.com/x-motemen/gore/cmd/gore@latest"
      "golang.org/x/tools/cmd/guru@latest"
      "github.com/themimitoof/ipg@latest"
      "github.com/sigstore/cosign/v2/cmd/cosign@latest"
    )
    for x in "${go_tools[@]}"; do
      distrobox enter --name fedora-toolbox-42 -- go install "$x"
    done

# Install Python tools
[group('install')]
hyperreal-install-python-tools:
    #!/usr/bin/env bash
    distrobox enter --name fedora-toolbox-42 -- pipx install --include-deps ansible --force

    py_tools=(
      "black"
      "bpython"
      "pyflakes"
      "isort"
      "pipenv"
      "nose"
      "pytest"
      "uv"
      "qbt-helper"
      "get-def"
      "print-wp-sources"
    )
    for x in "${py_tools[@]}"; do
      distrobox enter --name fedora-toolbox-42 -- pipx install "$x"
    done

    bpy_inject_tools=(
      "bs4"
      "requests"
      "rich"
      "qbittorrent-api"
    )
    for x in "${bpy_inject_tools[@]}"; do
      distrobox enter --name fedora-toolbox-42 -- pipx inject bpython "$x"
    done

# Upgrade Python tools
[group('install')]
hyperreal-upgrade-python-tools:
    #!/usr/bin/env bash
    distrobox enter --name fedora-toolbox-42 -- \
      pipx list --short | awk '{print $1}' | xargs pipx upgrade

# Install Node tools
[group('install')]
hyperreal-install-node-tools:
    #!/usr/bin/env bash
    node_tools=(
      "@bitwarden/cli"
      "@catppuccin/inkcat"
      "prettier"
      "js-beautify"
      "stylelint"
    )
    for x in "${node_tools[@]}"; do
      distrobox enter --name fedora-toolbox-42 -- sudo npm install -g "$x"
    done

# Install hyperreal flatpaks
[group('install')]
hyperreal-install-flatpaks:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Installing Flatpaks..."
    xargs -a <(curl --retry 3 -sL https://opengist.hyperreal.coffee/hyperreal/267127af54cf40678debb1ed618eefe3/raw/HEAD/bazzite-flatpaks.txt) flatpak --system -y install
    echo "Flatpaks installation complete."

# Setup pet distroboxes
[group('setup')]
hyperreal-setup-distroboxes:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! podman container exists debian-toolbox-13; then
      distrobox create -i github.com/hyperreal64/toolboxes/debian-toolbox:latest -n debian-toolbox-13
      echo "Successfully created debian-toolbox-13"
    else
      echo "Pet container debian-toolbox-13 already exists. Ignoring."
    fi

    if ! podman container exists fedora-toolbox-42; then
      distrobox create -i github.com/hyperreal64/toolboxes/fedora-toolbox:latest -n fedora-toolbox-42
      echo "Successfully created fedora-toolbox-42"
    else
      echo "Pet container fedora-toolbox-42 already exists. Ignoring."
    fi

# Setup git repos locally
[group('setup')]
hyperreal-setup-repos:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -f "${HOME}/.ssh/id_ed25519" ]; then
      echo "SSH key not found. Please ensure your SSH key is available."
      exit 1
    fi

    echo "Preparing local git directories..."
    mkdir -p "${HOME}/repos/github.com/hyperreal64"
    mkdir -p "${HOME}/repos/git.hyperreal.coffee/hyperreal"

    echo "Cloning repos from github.com/hyperreal64..."
    hyperreal_repos=("bluebuild-aurora" "bluebuild-bazzite" "toolboxes")
    for repo in "${hyperreal_repos[@]}"; do
      git clone "git@github.com:hyperreal64/${repo}.git" "${HOME}/repos/github.com/hyperreal64/${repo}"
    done

    echo "Cloning repos from git.hyperreal.coffee..."
    git_repos=("ansible-homelab" "dotfiles")
    for repo in "${git_repos[@]}"; do
      git clone "git@git.hyperreal.coffee:hyperreal/${repo}.git" "${HOME}/repos/git.hyperreal.coffee/hyperreal/${repo}"
    done

# Setup hyperreal configs
[group('setup')]
hyperreal-setup-cli:
    #!/usr/bin/env bash
    set -euo pipefail

    DOTFILES_DIR="${HOME}/repos/git.hyperreal.coffee/hyperreal/dotfiles"
    if [ ! -d "$DOTFILES_DIR" ]; then
      echo "${DOTFILES_DIR} not found."
      exit 1
    fi

    find "${DOTFILES_DIR}/config" -maxdepth 1 -mindepth 1 -exec ln -sf {} "${HOME}/.config" \;
    find "${DOTFILES_DIR}/zsh" -maxdepth 1 -mindepth 1 -exec ln -sf {} "${HOME}" \;
