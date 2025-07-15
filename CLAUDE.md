# CLAUDE.md

このファイルは、このリポジトリで作業する際のClaude Code (claude.ai/code) へのガイダンスを提供します。

## リポジトリ概要

これは複数のマシン間で個人設定ファイルを管理するための **chezmoi管理のdotfilesリポジトリ** です。Chezmoiは、テンプレート機能を通じてマシン固有の差異を処理する宣言的なdotfilesマネージャーです。

## よく使うコマンド

### Dotfiles管理
- `chezmoi apply` - dotfilesの変更をホームディレクトリに適用
- `chezmoi diff` - 適用される変更のプレビュー
- `chezmoi edit <file>` - 管理されているファイルを編集（設定されたエディタで開く）
- `chezmoi add <file>` - 新しいファイルをchezmoiの管理下に追加
- `chezmoi update` - ソースリポジトリから最新の変更を取得して適用

### 開発ワークフロー
1. ソースディレクトリ (`src/`) 内のファイルを変更
2. `chezmoi diff` で変更をテスト
3. `chezmoi apply` で変更を適用
4. gitに変更をコミット

### テスト
- tmuxプラグインのテスト: `cd src/dot_tmux/plugins/<plugin>/tests && ./run_tests`
- グローバルなテストスイートはなし；設定は適用することでテストされる

## アーキテクチャと構造

### ディレクトリ構成
- **ソースルート**: `src/` (`.chezmoiroot` で設定)
- **命名規則**: `dot_` プレフィックスはホームディレクトリで `.` になる（例：`dot_config` → `.config`）
- **テンプレート**: `.tmpl` で終わるファイルはマシン固有の値のためにGoテンプレートで処理される

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