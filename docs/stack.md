# 採用ソフトウェア・ライブラリ

このドキュメントは現在採用しているソフトウェアの全体マップです。**インストール経路** をカテゴリ列に明示しています。

凡例:
- 🟢 **Nix (Home Manager 共通)** — `nix/home/default.nix`
- 🍎 **Nix (macOS 専用)** — `nix/home/darwin.nix` または `nix/darwin/*.nix`
- 🐧 **Nix (Linux 専用)** — `nix/home/linux.nix`
- 🪟 **Nix (WSL2 専用)** — `nix/home/wsl.nix`
- 🍺 **Homebrew cask** — `nix/darwin/homebrew.nix` (macOS の GUI / Font 専用)
- 📦 **winget** — `winget.json` (Windows ネイティブ)
- 📜 **chezmoi script** — `src/.chezmoiscripts/`（apt パッケージ / Windows バイナリ等）

---

## シェル / プロンプト / ターミナル多重化

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `fish` | 🟢 | プライマリシェル。`programs.fish.enable` + `forgit` プラグイン |
| `starship` | 🟢 | プロンプト。fish 統合は `programs.starship.enableFishIntegration` |
| `tmux` | 🟢 | `programs.tmux.enable` + プラグイン (`sensible`, `resurrect`, `continuum`, `cpu`, `pain-control`, `nord`) |
| `zoxide` | 🟢 | `z` コマンドエイリアスで起動 |

## ターミナルエミュレータ

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| Wezterm | 🍺 (cask) | macOS の主力ターミナル。設定は `src/dot_config/wezterm/` |
| Windows Terminal | 📦 (Microsoft Store) | Windows ネイティブ |

> Alacritty は 2026-04 に GUI ライブラリのインストールエラー継続のため不採用化。

## エディタ

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `neovim` | 🟢 | Lua 設定 (`src/dot_config/nvim/`)。プラグイン管理は内蔵 |
| Cursor | 🍺 (cask) | AI エディタ |
| Visual Studio Code | 🍺 (cask) | |
| JetBrains Toolbox | 🍺 (cask) | IntelliJ / DataGrip / Goland 等の管理 |

## Git / 開発支援 CLI

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `git` | 🟢 | ベース Git |
| `delta` (`git-delta`) | 🟢 | Git diff 表示拡張 |
| `tig` | 🟢 | TUI Git クライアント |
| `gh` | 🟢 | GitHub CLI |
| `ghq` | 🟢 | リモートリポジトリ管理 |
| `gibo` | 🟢 | `.gitignore` ジェネレータ |
| `lazygit` (chezmoi 設定のみ管理、本体は別) | — | 設定は `src/dot_config/lazygit/` |

## 検索 / ファイル / 表示

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `bat` + `bat-extras` (batdiff/batgrep/batman/batpipe/batwatch/prettybat) | 🟢 | リッチ表示 cat |
| `eza` | 🟢 | リッチ表示 ls (`exa` の後継) |
| `fd` | 🟢 | 高速 find |
| `ripgrep` (`rg`) | 🟢 | 高速 grep |
| `fzf` | 🟢 | ファジーファインダ。fish 統合付き (`Ctrl-R` 等) |
| `tree` | 🟢 | |
| `htop` / `ncdu` | 🟢 | プロセス / ディスク使用率 |
| `tldr` | 🟢 | コマンド要約 |
| `glow` | 🟢 | TUI Markdown ビューア |
| `jq` | 🟢 | JSON 処理 |
| `yq` | 🟢 | YAML 処理 |
| `wget` | 🟢 | |
| `curlie` | 🟢 | curl をリッチに |

## ネットワーク / その他

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `iperf3` | 🟢 | スループット計測 |
| `act` | 🟢 | GitHub Actions ローカル実行 |
| `deno` | 🟢 | TS/JS ランタイム |
| `swagger-codegen3` | 🟢 | OpenAPI v3 codegen |
| `azure-cli` | 🪟 | WSL2 専用 |
| `awscli2` | 🪟 | WSL2 専用 |

## OS 補完ツール (macOS)

`nix/home/darwin.nix` で BSD coreutils を GNU 版で上書き、Linux と挙動を揃える:

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `coreutils` (GNU) | 🍎 | `ls`, `cp`, `mv`, `rm` 等を GNU 版に |
| `gnused`, `gawk`, `findutils`, `gnugrep` | 🍎 | sed/awk/find/grep を GNU 版に |
| `procps` | 🍎 | `watch` 等を提供 |

## OS 補完ツール (Linux ネイティブ)

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `xclip`, `wl-clipboard` | 🐧 | X11 / Wayland クリップボード |

## OS 補完ツール (WSL2)

| ソフトウェア | 経路 | 備考 |
|---|---|---|
| `azure-cli`, `awscli2` | 🪟 | クラウド CLI |
| `socat` | 📜 (apt) | 1Password ssh-agent 名前付きパイプブリッジ |
| `win32yank.exe` | 📜 | Windows クリップボードへの書き込み |
| `npiperelay.exe` | 📜 | Windows 名前付きパイプリレー (ssh-agent forwarding) |

---

## macOS GUI cask (`nix/darwin/homebrew.nix`)

`darwin-rebuild switch` の activation 中に `brew bundle` が自動実行され、宣言外の cask は `cleanup = "zap"` で uninstall されます。

### 認証 / セキュリティ

- 1Password / 1Password CLI

### 日本語 / IME / 翻訳

- ATOK
- DeepL

### コミュニケーション / 同期

- Slack
- Zoom
- Notion / Notion Calendar
- Obsidian
- Dropbox
- Google Drive

### 開発

- Cursor / Visual Studio Code
- JetBrains Toolbox
- Postman
- OrbStack（Docker Desktop 代替、軽量）
- Karabiner-Elements

### ブラウザ

- Google Chrome
- Microsoft Edge

### 生産性 / ユーティリティ

- Raycast (ランチャ)
- Path Finder (Finder 代替)
- Logi Options+
- ChatGPT / Claude / Claude Code
- Figma

### Microsoft Office

- Microsoft Office Business Pro
- Microsoft Auto Update

### Font (cask)

- HackGen / HackGen Nerd
- JetBrains Mono / JetBrains Mono Nerd Font
- UDEV Gothic / UDEV Gothic HS / UDEV Gothic NF

---

## Windows ネイティブ GUI (`winget.json`)

- 7zip
- Docker Desktop
- Firefox Developer Edition (ja)
- Git for Windows
- Volta
- Google Chrome
- Logitech Options+
- VIA (キーボード設定)
- Adobe Creative Cloud
- OBS Studio
- 1Password
- Canva
- Notion
- Claude
- AutoHotkey
- ほか `winget.json` 参照

---

## chezmoi で管理する設定ファイル

| 設定対象 | パス |
|---|---|
| fish | `src/dot_config/fish/` (関数 / OS 別 config / プラグインリスト) |
| zsh | `src/dot_zshrc.tmpl`, `src/dot_zsh/` |
| Neovim | `src/dot_config/nvim/` (Lua) |
| Wezterm | `src/dot_config/wezterm/` |
| Lazygit | `src/dot_config/lazygit/` |
| Starship | `src/dot_config/starship.toml` |
| Git | `src/dot_gitconfig.tmpl` (`{{ .email }}` 等のテンプレ変数) |
| tmux キーバインド | `nix/home/tmux.nix` 内の `extraConfig`（旧 `dot_tmux.conf` を移行済） |
| Karabiner-Elements | `src/dot_config/private_karabiner/karabiner.json.tmpl`（macOS のみ） |

詳細キーマップは [keymapping.md](./keymapping.md) 参照。
