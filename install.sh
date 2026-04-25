#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# Step 1: Install Nix via Determinate Systems Installer if missing.
# macOS / Linux / WSL2 supported. Skipped on plain Windows (uname != Darwin/Linux).
if ! command -v nix >/dev/null 2>&1; then
  case "$(uname)" in
    Darwin|Linux)
      echo "Installing Nix via Determinate Systems Installer..." >&2
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
      ;;
    *)
      echo "Skipping Nix install on $(uname). Continuing with chezmoi only." >&2
      ;;
  esac

  # Source Nix daemon env into this shell so subsequent commands see `nix`.
  NIX_PROFILE_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  # shellcheck disable=SC1090
  [ -f "$NIX_PROFILE_SCRIPT" ] && . "$NIX_PROFILE_SCRIPT"
fi

# Step 2: chezmoi bootstrap. Use existing chezmoi if available, else fetch
# the lightweight install script from get.chezmoi.io.
if ! chezmoi="$(command -v chezmoi)"; then
  bin_dir="${HOME}/.local/bin"
  chezmoi="${bin_dir}/chezmoi"
  echo "Installing chezmoi to '${chezmoi}'" >&2
  if command -v curl >/dev/null; then
    chezmoi_install_script="$(curl -fsSL get.chezmoi.io)"
  elif command -v wget >/dev/null; then
    chezmoi_install_script="$(wget -qO- get.chezmoi.io)"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
  sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
  unset chezmoi_install_script bin_dir
fi

# Step 3: Apply dotfiles. This clones the repo to ~/.local/share/chezmoi/
# and renders all chezmoi-managed files including the nix/ flake.
"$chezmoi" init --apply ispern

# Step 4: Bootstrap nix-darwin on macOS so CLI tools (fish, tmux, neovim, etc.)
# come from Nix instead of Homebrew. Idempotent: re-running just rebuilds.
#
# Sudo is only required for the first bootstrap (writing /etc/nix-darwin,
# /etc/zshenv, /run/current-system). Subsequent rebuilds use darwin-rebuild
# directly, which prompts for sudo internally only when activation needs root.
if [ "$(uname)" = "Darwin" ] && command -v nix >/dev/null 2>&1; then
  flake_path="$("$chezmoi" source-path)/../nix"
  if [ -d "$flake_path" ]; then
    if command -v darwin-rebuild >/dev/null 2>&1; then
      echo "Rebuilding nix-darwin from ${flake_path} (no sudo)..." >&2
      darwin-rebuild switch --flake "${flake_path}#default"
    else
      echo "Bootstrapping nix-darwin from ${flake_path} (sudo required)..." >&2
      sudo nix run nix-darwin -- switch --flake "${flake_path}#default"
    fi
  fi
fi
