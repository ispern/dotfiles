# CLAUDE.md

このファイルは、このリポジトリで作業する際のClaude Code (claude.ai/code) へのガイダンスを提供します。

## リポジトリ概要

これは複数のマシン間で個人設定ファイルを管理するための **chezmoi + Nix Flakes ハイブリッドの dotfiles リポジトリ** です。

| 責務 | ツール |
|---|---|
| CLI ツール（fish, tmux, neovim, eza 等）と将来的なシステム設定 | **Nix (nix-darwin + Home Manager)** — `nix/` 配下、`flake.lock` でハッシュ固定 |
| dotfiles 本体（`~/.config/**`、`~/.tmux.conf`、`~/.gitconfig` 等の設定ファイル） | **chezmoi** — `src/` 配下、Go テンプレートでマシン固有値を処理 |
| GUI アプリ・Font (macOS) | **Homebrew (cask)** — `Brewfile.darwin` |
| Windows ネイティブ | **winget** — `winget.json` |
| 言語ツールチェーン (Python/Ruby/Java) | **per-project flake + direnv**（このリポジトリでは管理しない） |

Nix と chezmoi のパスは重なりません（Nix は `~/.nix-profile/bin/` 配下のバイナリを、chezmoi は `~/.config/...` の設定ファイルを管理）。

## よく使うコマンド

### Nix (CLI ツール / システム)
- `darwin-rebuild switch --flake ./nix#default` - Nix 構成を適用
- `darwin-rebuild --rollback` - 直前の世代へ巻き戻し
- `nix flake update --flake ./nix` - inputs (nixpkgs 等) を最新化（明示的）
- 詳細は `nix/README.md`

### Dotfiles 管理 (chezmoi)
- `chezmoi apply` - dotfilesの変更をホームディレクトリに適用
- `chezmoi diff` - 適用される変更のプレビュー
- `chezmoi edit <file>` - 管理されているファイルを編集（設定されたエディタで開く）
- `chezmoi add <file>` - 新しいファイルをchezmoiの管理下に追加
- `chezmoi update` - ソースリポジトリから最新の変更を取得して適用

### 開発ワークフロー
- **CLI ツールの追加 / 削除**: `nix/home/default.nix` の `home.packages` を編集 → `darwin-rebuild switch --flake ./nix#default`
- **dotfiles の編集**: `src/` 内のファイルを変更 → `chezmoi diff` → `chezmoi apply`
- **GUI アプリ / Font**: `Brewfile.darwin` を編集 → `brew bundle --file=Brewfile.darwin`
- いずれの変更もコミット必須。Nix の場合は `nix/flake.lock` の更新もセットでコミット

### テスト
- tmuxプラグインのテスト: `cd src/dot_tmux/plugins/<plugin>/tests && ./run_tests`
- グローバルなテストスイートはなし；設定は適用することでテストされる

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