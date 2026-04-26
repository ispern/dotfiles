# CLAUDE.md

このファイルは、このリポジトリで作業する際のClaude Code (claude.ai/code) へのガイダンスを提供します。

## リポジトリ概要

これは複数のマシン間で個人設定ファイルを管理するための **chezmoi + Nix Flakes ハイブリッドの dotfiles リポジトリ** です。

| 責務 | ツール |
|---|---|
| CLI ツール（fish, tmux, neovim, eza 等）と macOS システム設定 (`defaults write`) | **Nix (nix-darwin + Home Manager)** — `nix/` 配下、`flake.lock` でハッシュ固定 |
| dotfiles 本体（`~/.config/**`、`~/.tmux.conf`、`~/.gitconfig` 等の設定ファイル） | **chezmoi** — `src/` 配下、Go テンプレートでマシン固有値を処理 |
| GUI アプリ・Font (macOS) | **nix-darwin `homebrew` モジュール** — `nix/darwin/homebrew.nix`（activation で `brew bundle` 自動実行） |
| Windows ネイティブ | **winget** — `winget.json` |
| 言語ツールチェーン (Python/Ruby/Java) | **per-project flake + direnv**（このリポジトリでは管理しない） |

Nix と chezmoi のパスは重なりません（Nix は `~/.nix-profile/bin/` 配下のバイナリを、chezmoi は `~/.config/...` の設定ファイルを管理）。

## よく使うコマンド

### Nix (CLI ツール / システム)
- macOS: `darwin-rebuild switch --flake ./nix#default` - 構成を適用
- macOS: `darwin-rebuild --rollback` - 直前の世代へ巻き戻し
- Linux: `nix run home-manager -- switch --flake ./nix#linux` - 構成を適用
- WSL2: `nix run home-manager -- switch --flake ./nix#wsl` - 構成を適用
- `nix flake update --flake ./nix` - inputs (nixpkgs 等) を最新化（明示的）
- 詳細は `nix/README.md`

### Dotfiles 管理 (chezmoi)
- `chezmoi apply` - dotfilesの変更をホームディレクトリに適用
- `chezmoi diff` - 適用される変更のプレビュー
- `chezmoi edit <file>` - 管理されているファイルを編集（設定されたエディタで開く）
- `chezmoi add <file>` - 新しいファイルをchezmoiの管理下に追加
- `chezmoi update` - ソースリポジトリから最新の変更を取得して適用

### 開発ワークフロー
- **CLI ツールの追加 / 削除（共通）**: `nix/home/default.nix` の `home.packages` を編集 → 各 OS で `switch` コマンドを実行
- **CLI ツールの追加 / 削除（OS 固有）**: `nix/home/{linux,wsl,darwin}.nix` を編集
- **dotfiles の編集**: `src/` 内のファイルを変更 → `chezmoi diff` → `chezmoi apply`
- **GUI アプリ / Font**: `nix/darwin/homebrew.nix` の `casks` を編集 → `darwin-rebuild switch --flake ./nix#default`（activation で `brew bundle` 自動実行）
- いずれの変更もコミット必須。Nix の場合は `nix/flake.lock` の更新もセットでコミット

### テスト
- **Nix flake の構文・評価**: `nix flake check ./nix --no-build --all-systems`（macOS 上で全 OS 構成を評価できる）
- **Linux / WSL2 の実ビルド検証** (`docker-compose.yml` / `Dockerfile` / `Dockerfile.wsl2`):
  - x86_64: `docker run --rm -v $(pwd):/workspace -w /workspace nixos/nix nix --extra-experimental-features "nix-command flakes" build ./nix#homeConfigurations.linux.activationPackage --no-link`
  - aarch64 (Apple Silicon の Docker はこちら): `homeConfigurations.linux-aarch64` を指定
  - WSL2: `homeConfigurations.wsl{,-aarch64}.activationPackage` に置き換え
  - install.sh の動作確認は `docker compose run --rm linux-interactive` / `wsl2-interactive` で対話シェルを起動して実行
- **tmux プラグインのテスト**: `cd src/dot_tmux/plugins/<plugin>/tests && ./run_tests`
- グローバルなテストスイートはなし；最終確認は `darwin-rebuild switch` / `home-manager switch` で実機適用してから動作確認

## アーキテクチャと構造

### ディレクトリ構成
- **chezmoi ソースルート**: `src/` (`.chezmoiroot` で設定)
- **chezmoi 命名規則**: `dot_` プレフィックスはホームディレクトリで `.` になる（例：`dot_config` → `.config`）
- **chezmoi テンプレート**: `.tmpl` で終わるファイルはマシン固有の値のためにGoテンプレートで処理される
- **Nix 構成**: `nix/` （`flake.nix`, `home/`, `darwin/`）— chezmoi 管理対象外

### 主要な設定エリア
1. **シェル環境**
   - Fish: `src/dot_config/fish/` - カスタム関数を持つプライマリシェル
   - Zsh: `src/dot_zshrc.tmpl`, `src/dot_zsh/` - 代替シェルセットアップ

2. **開発ツール**
   - Neovim: `src/dot_config/nvim/` - Luaベースの設定
   - Git: `src/dot_gitconfig.tmpl` - 豊富なエイリアスとdelta統合
   - tmux: `src/dot_tmux.conf`, `src/dot_tmux/plugins/` - セッション管理

3. **クロスプラットフォーム対応**
   - `.chezmoi.os` 経由でOSを検出（darwin、linux、windows）
   - SSHエージェント統合のための特別なWSL2処理
   - マシン固有のパス用のテンプレート変数

### テンプレート変数
Chezmoiは初回実行時にこれらについて尋ねます：
- `email` - git設定用のユーザーメール
- `workspaceRoot` - 開発プロジェクトのベースディレクトリ
- `editor` - 好みのテキストエディタコマンド

### 重要なパターン
- **FZF統合**: git、tmux、ファイル操作でのインタラクティブな選択にfzfを多用
- **シェル関数**: `src/dot_config/fish/functions/` 内の一般的なタスク用カスタム関数
- **プラグイン管理**: tmuxはプラグインにgitサブモジュールを使用

## 公開リポジトリ運用上の注意

このリポジトリは **GitHub で公開 (public)** されています。新規ファイル追加・編集時は以下を毎回確認してください:

- **シークレットを直接 commit しない**: API キー / トークン / パスワード等の認証情報、SSH 秘密鍵、メールアドレス・組織名・社内ホスト名の生値。マシン固有値は chezmoi テンプレート (`{{ .email }}`, `{{ .workspaceRoot }}` など) 経由でローカル展開すること
- **`private_` プレフィックスは git 除外ではない**: `src/dot_config/private_*/` の `private_` は chezmoi が apply 時にファイル権限を 0700 にする指示。**中身は公開リポジトリ上で誰でも読める**。シークレットを置く場所ではない（例: `private_karabiner/karabiner.json.tmpl` のキーマップは公開されている）
- **個人プロフィール露出は許容するが意識する**: `nix/darwin/homebrew.nix` の cask 一覧（インストール済 GUI アプリ）、`nix/darwin/system-defaults.nix` の UI/UX 好み設定は機密ではないが個人プロフィール情報。新規追加時に「公開して支障ないか」を判断する
- **真にローカル限定にしたい場合**: `.chezmoiignore` (chezmoi 管理から除外) または `.gitignore` (git 管理から除外) を使う