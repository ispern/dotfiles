#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# 非対話シェル（コンテナ内 `bash -c`、sudo --preserve-env なし、cron 等）では
# USER / LOGNAME が未設定のことがあり、home-manager が unbound variable で落ちる。
# 実害が無い範囲で補完しておく。
: "${USER:=$(id -un)}"
: "${LOGNAME:=$USER}"
export USER LOGNAME

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
# テスト用の上書き:
#   DOTFILES_REPO=/path/to/repo  ローカルの git リポジトリから clone（push 不要の検証用）
#   DOTFILES_BRANCH=feature/xxx  GitHub の特定ブランチから clone
if [ -n "${DOTFILES_REPO:-}" ]; then
  echo "Initializing chezmoi from local repo '${DOTFILES_REPO}'" >&2
  "$chezmoi" init --apply "${DOTFILES_REPO}"
elif [ -n "${DOTFILES_BRANCH:-}" ]; then
  echo "Initializing chezmoi from branch '${DOTFILES_BRANCH}'" >&2
  "$chezmoi" init --apply --branch "${DOTFILES_BRANCH}" ispern
else
  "$chezmoi" init --apply ispern
fi

# Step 4: OS 別に Nix 構成を適用する。
# - macOS: nix-darwin (sudo 必須、システム activation のため)
# - Linux / WSL2: standalone Home Manager (sudo 不要)
if command -v nix >/dev/null 2>&1; then
  flake_path="$("$chezmoi" source-path)/../nix"
  if [ -d "$flake_path" ]; then
    case "$(uname)" in
      Darwin)
        echo "Applying nix-darwin from ${flake_path} (sudo required)..." >&2
        sudo nix run nix-darwin -- switch --flake "${flake_path}#default"
        ;;
      Linux)
        # /proc/version に "microsoft" を含めば WSL2。テスト時は DOTFILES_FORCE_WSL=1 で強制可。
        if [ "${DOTFILES_FORCE_WSL:-}" = "1" ] || grep -qi microsoft /proc/version 2>/dev/null; then
          home_target="wsl"
        else
          home_target="linux"
        fi
        # aarch64 WSL/Linux ホスト向けに -aarch64 bundle に切替
        case "$(uname -m)" in
          aarch64|arm64) home_target="${home_target}-aarch64" ;;
        esac
        echo "Applying Home Manager (${home_target}) from ${flake_path}..." >&2
        nix run home-manager/master -- switch --flake "${flake_path}#${home_target}"
        ;;
    esac
  fi
fi
