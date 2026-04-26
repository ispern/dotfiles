dotfiles
========

複数のマシンにまたがる個人用設定を **chezmoi + Nix Flakes** で宣言的に管理するためのリポジトリ。

## 環境マトリクス

| 環境 | パッケージ管理 | 設定ファイル |
|---|---|---|
| **macOS** | Nix (nix-darwin + Home Manager) — CLI<br>nix-darwin `homebrew` モジュール経由 — GUI cask + Font | chezmoi |
| **Linux / WSL2** | Nix (Home Manager standalone) — CLI<br>apt — `socat` 等システム依存のみ | chezmoi |
| **Windows ネイティブ** | winget | chezmoi |

サプライチェーン耐性のため CLI ツールも GUI cask も `flake.lock` + `nix/darwin/homebrew.nix` で宣言管理。`darwin-rebuild switch` 一発でマシン全体が再現可能です。

## ディレクトリ構成

```
.
├── nix/              # Nix Flakes (CLI 管理) — chezmoi 管理対象外
│   ├── flake.nix
│   ├── home/         # Home Manager
│   └── darwin/       # nix-darwin (macOS only)
├── src/              # chezmoi ソース (.chezmoiroot で指定)
│   ├── dot_config/   # → ~/.config/
│   ├── dot_*.tmpl    # マシン固有値を含むテンプレート
│   └── .chezmoiscripts/
└── winget.json       # Windows パッケージ
```

## 初回セットアップ

### macOS（ワンライナー）

```sh
curl -fsSL https://raw.githubusercontent.com/ispern/dotfiles/main/install.sh | sh
```

`install.sh` が以下を順に実行します:

1. Determinate Systems Installer で Nix を導入（既存ならスキップ）
2. `chezmoi` をインストール（既存ならスキップ）
3. `chezmoi init --apply ispern` でリポジトリを取得し dotfiles を適用
4. `sudo nix run nix-darwin -- switch --flake ./nix#default` で CLI 環境と GUI cask / Font を構築

GUI cask / Font は `nix/darwin/homebrew.nix` に declarative 宣言され、`darwin-rebuild switch` の activation で `brew bundle` が自動実行されます (Homebrew 自体の bootstrap は chezmoi の `run_once_before_00_install-homebrew.sh` が担当)。

完了後の追加ステップ:

```sh
# fish をデフォルトシェルに
chsh -s "$(which fish)"
```

### macOS（手動セットアップ）

ワンライナーを使わず段階的に進める場合は [`nix/README.md`](./nix/README.md) を参照。

### Windows

`winget import winget.json` で一括インストール。dotfiles 本体は WSL2 経由で chezmoi 適用。

### Linux / WSL2（ワンライナー）

```sh
curl -fsSL https://raw.githubusercontent.com/ispern/dotfiles/main/install.sh | sh
```

未マージのブランチを検証したい場合は `DOTFILES_BRANCH` を指定:

```sh
DOTFILES_BRANCH=feature/xxx sh install.sh
```

`install.sh` は `/proc/version` から WSL2 を検出して、適切な Home Manager 構成を自動選択します:

- Linux ネイティブ → `nix run home-manager -- switch --flake ./nix#linux`
- WSL2 → `nix run home-manager -- switch --flake ./nix#wsl`

WSL2 では別途 `socat` (1Password ssh-agent 用) と `win32yank.exe` / `npiperelay.exe`（Windows 側バイナリ）が chezmoi スクリプトで配置されます。

完了後の追加ステップ:

```sh
# fish をデフォルトシェルに（Nix 管理の fish パスを /etc/shells に追加してから）
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"
```

## 移行ステータス

- [x] **Phase 1**: macOS CLI を Nix へ移行
- [ ] **Phase 1.x**: fish プラグイン (fisher → `programs.fish.plugins`)、tmux プラグイン (TPM → `programs.tmux.plugins`) を Home Manager 管理に移行
- [x] **Phase 2**: Linux / WSL の CLI を Nix へ移行
- [x] **Phase 3a**: macOS システム設定 (`defaults write`) を nix-darwin に宣言化
- [x] **Phase 3b**: GUI cask + Font を nix-darwin の `homebrew` モジュールで宣言化
- [ ] **Phase 3c**: TouchID for sudo / LaunchAgents（任意）

## ライセンス

このリポジトリ内の自作スクリプトは MIT ライセンス。サードパーティのプラグイン（`src/dot_tmux/plugins/` 等）は各々のライセンスに従う。
