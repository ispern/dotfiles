#!/bin/sh

# -e: エラー時に即終了
# -u: 未定義変数の参照で即終了
set -eu

# 非対話シェル（コンテナ内 `bash -c`、sudo --preserve-env なし、cron 等）では
# USER / LOGNAME が未設定のことがあり、home-manager が unbound variable で落ちる。
# 実害が無い範囲で補完しておく。
: "${USER:=$(id -un)}"
: "${LOGNAME:=$USER}"
export USER LOGNAME

# Step 1: Nix が未インストールなら Determinate Systems Installer で導入する。
# macOS / Linux / WSL2 に対応。ネイティブ Windows (uname != Darwin/Linux) ではスキップ。
if ! command -v nix >/dev/null 2>&1; then
  case "$(uname)" in
    Darwin|Linux)
      echo "Determinate Systems Installer で Nix を導入します..." >&2
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
      ;;
    *)
      echo "$(uname) では Nix のインストールをスキップし、chezmoi のみ続行します。" >&2
      ;;
  esac

  # 後続コマンドが nix コマンドを見つけられるよう、Nix daemon 環境を読み込む。
  NIX_PROFILE_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  # shellcheck disable=SC1090
  [ -f "$NIX_PROFILE_SCRIPT" ] && . "$NIX_PROFILE_SCRIPT"
fi

# Step 2: chezmoi の bootstrap。既に存在すれば再利用、無ければ get.chezmoi.io
# の軽量インストーラを取得して導入する。
if ! chezmoi="$(command -v chezmoi)"; then
  bin_dir="${HOME}/.local/bin"
  chezmoi="${bin_dir}/chezmoi"
  echo "chezmoi を '${chezmoi}' にインストールします" >&2
  if command -v curl >/dev/null; then
    chezmoi_install_script="$(curl -fsSL get.chezmoi.io)"
  elif command -v wget >/dev/null; then
    chezmoi_install_script="$(wget -qO- get.chezmoi.io)"
  else
    echo "chezmoi のインストールには curl または wget が必要です。" >&2
    exit 1
  fi
  sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
  unset chezmoi_install_script bin_dir
fi

# Step 3: dotfiles を適用する。リポジトリを ~/.local/share/chezmoi/ に clone し、
# nix/ flake を含む chezmoi 管理ファイルを全てレンダリング・配置する。
# テスト用の上書き:
#   DOTFILES_REPO=/path/to/repo  ローカルの git リポジトリから clone（push 不要の検証用）
#   DOTFILES_BRANCH=feature/xxx  GitHub の特定ブランチから clone
if [ -n "${DOTFILES_REPO:-}" ]; then
  echo "ローカルリポジトリ '${DOTFILES_REPO}' から chezmoi を初期化します" >&2
  "$chezmoi" init --apply "${DOTFILES_REPO}"
elif [ -n "${DOTFILES_BRANCH:-}" ]; then
  echo "ブランチ '${DOTFILES_BRANCH}' から chezmoi を初期化します" >&2
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
        echo "${flake_path} から nix-darwin を適用します（sudo が必要）..." >&2
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
        echo "${flake_path} から Home Manager (${home_target}) を適用します..." >&2
        nix run home-manager/master -- switch --flake "${flake_path}#${home_target}"
        ;;
    esac
  fi
fi
