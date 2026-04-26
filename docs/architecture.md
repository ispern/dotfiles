# アーキテクチャ

## 設計方針

複数 OS にまたがる開発環境を **再現性 / メンテ性 / プラットフォーム適合性** の 3 軸で最適化するため、4 系統のツールを **責務で分離** したハイブリッド設計を採用しています。

| 責務 | 採用ツール | 採用理由 |
|---|---|---|
| CLI ツール（fish, tmux, neovim, eza, ripgrep, jq 等） | **Nix Flakes (Home Manager)** | `flake.lock` でハッシュ固定 → サプライチェーン耐性。OS 横断で同じバージョンを再現 |
| dotfiles（`~/.config/**`, `~/.tmux.conf`, `~/.gitconfig` 等） | **chezmoi** | Go テンプレートでマシン固有値（メール、パス）を OS 別に展開可能 |
| macOS システム設定 (`defaults write`) と GUI cask + Font | **nix-darwin** (`system.defaults` + `homebrew` モジュール) | macOS 全体を `darwin-rebuild switch` 1 コマンドで再現可能に |
| Windows ネイティブの GUI アプリ | **winget** (`winget.json`) | Microsoft 公式パッケージマネージャ、Microsoft Store と統合済 |

> 言語ツールチェーン (Python / Ruby / Java / Node) は **per-project flake + direnv** で管理し、グローバルには入れません。

## ディレクトリ構成

```
.
├── install.sh                  # OS 自動判定の bootstrap (curl パイプで実行可)
├── README.md                   # クイックスタート
├── CLAUDE.md / AGENTS.md       # AI エージェント向けガイダンス
├── nix/                        # Nix Flakes (chezmoi 管理対象外)
│   ├── flake.nix               # inputs: nixpkgs / nix-darwin / home-manager (release-25.11)
│   ├── flake.lock              # ハッシュ固定 (コミット必須)
│   ├── home/
│   │   ├── default.nix         # 全 OS 共通の home.packages + programs.*
│   │   ├── darwin.nix          # macOS 固有: GNU coreutils 等
│   │   ├── linux.nix           # Linux 固有: xclip, wl-clipboard
│   │   ├── wsl.nix             # WSL2 固有: azure-cli, awscli2
│   │   ├── fish.nix            # programs.fish + forgit プラグイン
│   │   └── tmux.nix            # programs.tmux + プラグイン (sensible/resurrect/continuum/pain-control/nord)
│   └── darwin/
│       ├── default.nix         # nix-darwin: hostname / fish login shell / 共通設定
│       ├── system-defaults.nix # macOS UI/UX (Dock / Finder / NSGlobalDomain / trackpad / locale 等)
│       └── homebrew.nix        # GUI cask + Font (declarative `brew bundle`)
├── src/                        # chezmoi ソースルート (.chezmoiroot で指定)
│   ├── dot_config/             # → ~/.config/
│   │   ├── fish/               # fish 関数群 / シェル設定
│   │   ├── nvim/               # Neovim Lua 設定
│   │   ├── lazygit/, wezterm/, starship.toml
│   │   └── private_karabiner/  # Karabiner-Elements (private_ は chezmoi の権限指示で git 除外ではない)
│   ├── dot_zshrc.tmpl, dot_gitconfig.tmpl 等  # マシン固有値テンプレート
│   ├── dot_tmux/plugins/       # tmux プラグイン (TPM, git submodule)
│   └── .chezmoiscripts/        # OS 別の bootstrap スクリプト群
│       ├── darwin/             # Homebrew 自体のインストール
│       ├── linux/wsl/          # apt (socat) / win32yank / npiperelay
│       └── windows/            # winget import
├── docs/                       # このディレクトリ
└── winget.json                 # Windows GUI アプリ宣言
```

## install.sh の実行フロー

```
install.sh
  │
  ├─ Step 1: Nix のインストール（未導入時のみ）
  │     - macOS / Linux / WSL2 → Determinate Systems Installer
  │     - Windows ネイティブ → スキップ（chezmoi のみ続行）
  │
  ├─ Step 2: chezmoi のインストール（未導入時のみ）
  │     - get.chezmoi.io のスクリプトを ~/.local/bin に
  │
  ├─ Step 3: chezmoi init --apply ispern
  │     - リポジトリを ~/.local/share/chezmoi/ に clone
  │     - .tmpl をレンダリングして dotfiles を home に配置
  │     - .chezmoiscripts/{darwin,linux/wsl,windows}/ の run_once_before_* が走る
  │       (Homebrew 本体 / apt パッケージ / win32yank / npiperelay)
  │
  └─ Step 4: OS 別 Nix 構成適用
        - macOS  → sudo nix run nix-darwin -- switch --flake ./nix#default
                   (CLI + system.defaults + GUI cask を一括適用)
        - Linux  → nix run home-manager/master -- switch --flake ./nix#linux
        - WSL2   → nix run home-manager/master -- switch --flake ./nix#wsl
                   (aarch64 ホストは自動的に -aarch64 サフィックス付き bundle へ)
```

## OS 別の差分

### macOS (`ispern-mac-mini` 等)

- **`nix-darwin` を使う** — Linux/WSL2 とここが最大の違い
- **CLI + システム設定 + GUI cask が 1 コマンド** で揃う
  - `system.defaults` (Dock/Finder/NSGlobalDomain/trackpad/screencapture/loginwindow/LaunchServices/locale)
  - `homebrew` モジュールが activation 中に `brew bundle` を自動実行 (`onActivation.cleanup = "zap"` で宣言外 cask を uninstall)
- **GNU coreutils を Nix から提供** (`coreutils`, `gnused`, `gawk`, `findutils`, `gnugrep`, `procps`) して BSD ツールを上書き、Linux と挙動を揃える
- **`home.activation.chezmoiApply`** が `darwin-rebuild switch` の最後に `chezmoi apply` を自動実行 → Nix 管理 (CLI / programs.\*) と chezmoi 管理 (~/.config/\* dotfiles) を 1 コマンドで同期
- Karabiner-Elements は GUI cask、設定ファイルは chezmoi (`src/dot_config/private_karabiner/karabiner.json.tmpl`)
- TouchID for sudo は将来オプション（Mac mini はハードウェア未対応のため見送り）

### Linux ネイティブ

- **standalone Home Manager** — `nix-darwin` 相当のシステム改変は無し
- **sudo 不要** — すべてユーザプロファイル (`~/.nix-profile/bin/`) にインストール
- **Linux 固有パッケージ**: `xclip`, `wl-clipboard` (X11/Wayland クリップボード連携)
- システム依存（fish を `/etc/shells` に追加するなど）はユーザが手動

### WSL2 (Ubuntu 等)

Linux ネイティブと共通基盤に **WSL 専用の追加要素**:

- **検出**: `/proc/version` に `microsoft` を含むかで判定（`DOTFILES_FORCE_WSL=1` で強制可）
- **flake bundle**: `homeConfigurations.wsl{,-aarch64}` を選択
- **WSL 専用 Nix パッケージ**: `azure-cli`, `awscli2` (旧 `chezmoiscripts/.../03,04` の置換)
- **クリップボード連携**: `xclip` ではなく Windows 側 `win32yank.exe` を使う（chezmoi スクリプトで `~/bin/win32yank.exe` 配置 → tmux の copy-mode-vi バインドが `cat | win32yank.exe -i` を呼ぶ）
- **1Password ssh-agent ブリッジ**:
  - apt で `socat` をインストール（`chezmoiscripts/linux/wsl/run_once_before_05_install-apt.sh.tmpl`）
  - `~/bin/npiperelay.exe` 配置（Windows 側名前付きパイプリレー、`chezmoiscripts/.../07_install-npiperelay.sh.tmpl`）
  - fish 起動時に `socat` + `npiperelay` で Windows の 1Password ssh-agent パイプにブリッジ

### Windows ネイティブ

- **CLI 環境は WSL2 経由で完結** — Windows 側で chezmoi/Nix を直接動かさない
- **GUI アプリのみ winget で管理**: `winget import winget.json`
- 自動化スクリプト: `src/.chezmoiscripts/windows/run_once_before_00_install-packages.ps1.tmpl`

## chezmoi 命名規則と運用上の注意

- **`dot_` プレフィックス**: ホームディレクトリで `.` に変換される（例: `dot_config` → `.config`）
- **`.tmpl` サフィックス**: Go テンプレートで処理。`{{ .email }}`, `{{ .workspaceRoot }}`, `{{ .editor }}`, `{{ if eq .chezmoi.os "darwin" }}` 等が使える
- **`private_` プレフィックス**: chezmoi が apply 時にファイル権限を 0700 にする指示。**git からの除外ではない**ため、シークレットを置く場所ではない
- **`run_once_before_*`**: chezmoi apply 前に **1 回だけ** 実行されるスクリプト
- **`.chezmoiscripts/`**: dotfiles 配置とは独立した bootstrap ロジック（外部ツールのインストール等）
- **テンプレート変数の取得**: 初回 `chezmoi init` で対話的に質問される（メール、ワークスペースパス、エディタ等）

## サプライチェーン耐性

- **Nix の `flake.lock`**: nixpkgs / nix-darwin / home-manager の commit ハッシュを固定。`nix flake update` を明示的に走らせない限り再現性が壊れない
- **nix-darwin の `homebrew` モジュール**: `Brewfile` の役割を Nix で declarative 化。`flake.lock` ＋ `homebrew.casks` リスト ＋ `system.defaults` でマシン全体が再現可能
- **chezmoi の git 同期**: dotfiles 本体の差分追跡。レンダリング後の `~/.gitconfig` 等は machine-specific だが、テンプレートはリポジトリで一元管理

## 関連ドキュメント

- [setup.md](./setup.md) — OS 別セットアップ手順の詳細
- [stack.md](./stack.md) — 採用ソフトウェア・ライブラリ一覧
- [keymapping.md](./keymapping.md) — キーマップリファレンス
- [`../nix/README.md`](../nix/README.md) — Nix 構成の運用日常マニュアル
