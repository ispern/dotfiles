# nix/ — Nix で管理する CLI 環境

このディレクトリは **macOS / Linux / WSL の CLI ツール群と、macOS の システム設定 / GUI cask を Nix Flakes で宣言管理** するための設定です。`flake.lock` でハッシュ固定し、サプライチェーンの再現性を確保します。

macOS では GUI アプリ（cask）と Font も `nix/darwin/homebrew.nix` 経由で nix-darwin に宣言化されており、`darwin-rebuild switch` の activation で `brew bundle` が自動実行されます。Windows ネイティブのみ `winget.json` で管理します。chezmoi はこれまで通り dotfiles 本体を管理します。

## 構成

```
nix/
├── flake.nix              # inputs: nixpkgs / nix-darwin / home-manager
├── home/
│   ├── default.nix        # 全環境共通の home.packages + programs.*
│   └── darwin.nix         # macOS 固有 (GNU coreutils 等)
└── darwin/
    ├── default.nix        # nix-darwin: hostname / 共通システム設定
    ├── system-defaults.nix # macOS UI/UX (Dock / Finder / Trackpad / Locale 等)
    └── homebrew.nix       # GUI cask + Font (declarative `brew bundle`)
```

`darwinConfigurations` のキーは LocalHostName。複数 Mac で使い回す場合は `flake.nix` の `mkDarwin` を再利用してエントリを追加します。

## 初回セットアップ（macOS）

### 1. Nix のインストール

[Determinate Systems Installer](https://determinate.systems/posts/determinate-nix-installer/) を使います。公式 multi-user installer よりクリーンに uninstall できます。

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

ターミナルを開き直して `nix --version` が通ることを確認します。Flakes と nix-command は Determinate Installer で既定有効です。

### 2. nix-darwin の bootstrap

```sh
cd /Users/h.matsuoka/workspace/github.com/ispern/dotfiles
sudo nix run nix-darwin -- switch --flake ./nix#default
```

初回のみ sudo を要求されます。以降は通常ユーザーで実行可能：

```sh
darwin-rebuild switch --flake ./nix#default
```

ホスト名が `ispern-mac-mini` 以外の場合は `flake.nix` の `darwinConfigurations` にエントリを追加してから上記コマンドを実行します。

### 3. 動作確認

```sh
which fish bat eza fd ripgrep tmux nvim git delta zoxide
# 期待: /run/current-system/sw/bin/ または /etc/profiles/per-user/h.matsuoka/bin/

z --help    # zoxide が起動 (`--cmd z` でコマンド名は維持)
```

## 日常運用

### パッケージを追加 / 削除

`home/default.nix` の `home.packages` を編集して以下を実行：

```sh
darwin-rebuild switch --flake ./nix#default
```

### `nixpkgs` のバージョン更新（明示的アップデート）

```sh
cd nix
nix flake update                  # 全 inputs を更新
nix flake update nixpkgs          # nixpkgs のみ
darwin-rebuild switch --flake .#default
```

`flake.lock` を更新せずに `darwin-rebuild` を回している限り、ロックされたバージョンが固定で再現されます。

### 巻き戻し（破損時）

```sh
darwin-rebuild --rollback     # 直前の世代へ戻す
darwin-rebuild --list-generations
```

## chezmoi との責務分担

| 対象 | 管理者 |
|---|---|
| CLI ツール（fish, tmux, neovim, eza, ripgrep など） | **Nix (Home Manager)** |
| GUI アプリ・Font (macOS) | **nix-darwin `homebrew` モジュール** (`nix/darwin/homebrew.nix`) |
| macOS システム設定 (`defaults write` 等) | **nix-darwin `system.defaults`** (`nix/darwin/system-defaults.nix`) |
| シェル / エディタの設定ファイル (`~/.config/fish/*.fish`, `~/.tmux.conf`, `~/.config/nvim/**`) | **chezmoi** |
| マシン固有値（メールアドレス、ワークスペースパス等） | **chezmoi テンプレート** |
| 言語ツールチェーン (Python, Ruby, Java) | **per-project flake + direnv**（global 管理しない） |

Nix が `~/.nix-profile/bin` 経由で CLI を提供し、chezmoi は `~/.config/...` のファイル群を管理します。両者のパスは重なりません。

## 既知の制限（Phase 1 時点）

- **fish プラグイン管理** は当面 fisher（chezmoi の `dot_config/fish/fish_plugins`）に依存。`programs.fish.enable` 化は Phase 1.x 後続 PR で実施予定
- **tmux プラグイン管理** は当面 TPM（chezmoi の `dot_tmux/plugins/`）に依存。`programs.tmux.enable` 化は Phase 1.x 後続 PR で実施予定
- **Linux / WSL** の対応は Phase 2 で実装予定（同一 `home/default.nix` を流用）
