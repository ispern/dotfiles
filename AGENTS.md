# AGENTS.md

このファイルは、AIコーディングエージェントがこのdotfilesプロジェクトで作業する際の詳細なガイダンスを提供します。

## プロジェクト概要

このプロジェクトは、chezmoiを使用したdotfiles管理システムです。複数のOS（macOS、Linux、WSL2）と環境（Codespaces、Remote Containers）に対応した設定ファイルを管理しています。

## Setup commands (セットアップコマンド)

### 前提条件
- chezmoiがインストールされている必要があります
- 各OSに応じたパッケージマネージャー（Homebrew、apt等）が必要です

### 初期セットアップ
```bash
# 1. chezmoiのインストール（未インストールの場合）
curl -fsSL get.chezmoi.io | sh

# 2. dotfilesの初期化と適用
./install.sh
# または
chezmoi init --apply ispern
```

### 開発環境のセットアップ
```bash
# 1. 依存関係のインストール（macOS）
brew bundle install

# 2. chezmoiの設定確認
chezmoi status

# 3. 設定ファイルの適用
chezmoi apply
```

### テスト実行
```bash
# 1. chezmoiの設定検証
chezmoi check

# 2. 設定ファイルの差分確認
chezmoi diff

# 3. ドライラン（実際の変更は行わない）
chezmoi apply --dry-run
```

## Code style (コードスタイル)

### 全般的なルール
- **一貫性を最優先**: 既存のコードスタイルに厳密に従う
- **テンプレート構文の遵守**: chezmoiのテンプレート構文（`{{ }}`）を正確に使用
- **コメントの適切な配置**: 複雑な設定には必ずコメントを追加
- **ファイル命名規則**: `.tmpl`拡張子を適切に使用

### 設定ファイル別のスタイル

#### chezmoiテンプレート（.tmpl）
```bash
# 条件分岐の適切な使用
{{- if eq .chezmoi.os "darwin" }}
# macOS固有の設定
{{- else if eq .chezmoi.os "linux" }}
# Linux固有の設定
{{- end }}

# 環境変数の安全な使用
{{- $wsl2 := and (eq .chezmoi.os "linux") (.chezmoi.kernel.osrelease | lower | contains "microsoft") }}
```

#### Lua設定（Neovim）
```lua
-- インデント: 2スペース
-- 文字列: シングルクォートを優先
-- 関数定義: local functionを使用
local function setup_plugin()
  -- 設定内容
end
```

#### Fish Shell設定
```fish
# 関数定義のスタイル
function function_name
    # インデント: 4スペース
    # コマンド実行
end
```

#### TOML設定（Starship等）
```toml
# セクションの適切なグループ化
[section_name]
key = "value"
nested_key = "nested_value"
```

## Testing instructions (テストの指示)

### 必須テストコマンド（コミット前）
**重要**: エージェントは以下のテストコマンドを自動的に実行し、タスク完了前に失敗を修正する必要があります。

```bash
# 1. chezmoiの設定検証（必須）
chezmoi check

# 2. ドライランでの動作確認（必須）
chezmoi apply --dry-run

# 3. 設定ファイルの差分確認
chezmoi diff

# 4. テンプレートの構文チェック
chezmoi execute-template --template '{{ .chezmoi.sourceDir }}'

# 5. 設定ファイルの構文チェック（必須）
fish -n ~/.config/fish/config.fish 2>/dev/null || true
nvim --headless -c 'lua print("Config OK")' -c 'quit' 2>/dev/null || true
```

### CIプランとテスト実行
- **CIプランの場所**: このプロジェクトはchezmoiベースのため、CIは各環境での手動テストに依存
- **全チェック実行コマンド**: `chezmoi check && chezmoi apply --dry-run`
- **テスト環境の分類**:
  - **ホストで実行**: macOS、WSL2
  - **Dockerで実行**: Linux、WSL2（シミュレート）、Remote Containers、Codespaces
- **環境変数フラグのテスト**: REMOTE_CONTAINERS、CODESPACESフラグによる挙動の違いを検証
- **特定の設定テスト**: 各設定ファイルの構文チェックを個別実行
- **ファイル変更後のチェック**: 設定ファイル変更後は必ずchezmoiの検証を実行

### 環境別テスト

#### macOS環境（ホストで実行）
```bash
# Homebrewパッケージの確認
brew bundle check

# 設定ファイルの構文チェック
fish -n ~/.config/fish/config.fish
nvim --headless -c 'lua print("Config loaded successfully")' -c 'quit'
tmux -f ~/.tmux.conf -C list-commands > /dev/null
```

#### WSL2環境（ホストで実行）
```bash
# WSL2固有のテスト
# パッケージマネージャーに応じたテストを実行

# 設定ファイルの構文チェック
fish -n ~/.config/fish/config.fish
nvim --headless -c 'lua print("Config loaded successfully")' -c 'quit'
tmux -f ~/.tmux.conf -C list-commands > /dev/null
```

#### Linux環境（Docker使用）
```bash
# 1. Dockerコンテナの起動
docker-compose up -d linux-interactive

# 2. コンテナ内でのテスト実行
docker-compose exec linux-interactive bash -c "
  # まっさらな環境でのinstall.shテスト
  ./install.sh
  
  # インストール後の設定確認
  chezmoi status
  chezmoi diff
  
  # 設定ファイルの構文チェック
  fish -n ~/.config/fish/config.fish 2>/dev/null || echo 'Fish not installed yet'
  nvim --headless -c 'lua print(\"Config OK\")' -c 'quit' 2>/dev/null || echo 'Neovim not installed yet'
"

# 3. コンテナの停止とクリーンアップ
docker-compose down
```

#### WSL2環境（Docker使用）
```bash
# 1. WSL2環境のDockerコンテナ起動
docker-compose up -d wsl2-interactive

# 2. WSL2環境でのテスト実行
docker-compose exec wsl2-interactive bash -c "
  # WSL2環境でのinstall.shテスト
  ./install.sh
  
  # WSL2環境の設定確認
  chezmoi status
  chezmoi diff
"

# 3. コンテナの停止とクリーンアップ
docker-compose down
```

#### Remote Containers環境（Docker使用）
```bash
# 1. Remote Containers環境のDockerコンテナ起動
docker-compose up -d remote-containers-interactive

# 2. Remote Containers環境でのテスト実行
docker-compose exec remote-containers-interactive bash -c "
  # REMOTE_CONTAINERS=true環境でのinstall.shテスト
  ./install.sh
  
  # 環境変数からの設定取得確認
  chezmoi data | jq '.remoteContainers'
  chezmoi data | jq '.email'
  chezmoi data | jq '.workspaceRoot'
  chezmoi data | jq '.editor'
"

# 3. コンテナの停止とクリーンアップ
docker-compose down
```

#### Codespaces環境（Docker使用）
```bash
# 1. Codespaces環境のDockerコンテナ起動
docker-compose up -d codespaces-interactive

# 2. Codespaces環境でのテスト実行
docker-compose exec codespaces-interactive bash -c "
  # CODESPACES=true環境でのinstall.shテスト
  ./install.sh
  
  # 環境変数からの設定取得確認
  chezmoi data | jq '.codespaces'
  chezmoi data | jq '.email'
  chezmoi data | jq '.workspaceRoot'
  chezmoi data | jq '.editor'
"

# 3. コンテナの停止とクリーンアップ
docker-compose down
```

### テスト追加・更新の義務
- **変更したコードには必ずテストを追加または更新すること**
- 新しい設定ファイルを追加した場合、対応するテストケースを作成
- 既存の設定を変更した場合、関連するテストを更新

### テスト失敗時の対応
- **テストが失敗した場合、コミットは絶対に禁止**
- エラーメッセージを詳細に分析し、根本原因を特定
- 修正後、全テストを再実行して成功を確認

## PR instructions (プルリクエストの指示)

### プルリクエストタイトルフォーマット
```
[OS/環境] 機能名: 簡潔な説明

例:
[macOS] Neovim: LSP設定の更新
[Linux] Fish: 新しいエイリアスの追加
[共通] chezmoi: テンプレート変数の修正
```

### コミット前の必須チェックリスト
```bash
# 1. 全テストの実行（必須）
chezmoi check && chezmoi apply --dry-run

# 2. 設定ファイルの構文チェック
fish -n ~/.config/fish/config.fish 2>/dev/null || true
nvim --headless -c 'lua print("Config OK")' -c 'quit' 2>/dev/null || true

# 3. 差分の確認
chezmoi diff

# 4. ドキュメントの更新確認
# 変更がユーザーに影響する場合は、README.mdの更新を検討
```

### PR作成時の注意事項
- **変更の影響範囲を明確に記載**
- **テスト結果のスクリーンショットを添付**
- **既存の設定との互換性を確認**
- **複数OSでの動作確認結果を記載**

## 大規模な作業と計画管理 (Exec Plan & Plans.md)

### 複雑なタスクの実行計画
7時間以上にわたる複雑なリファクタリング（15,000行以上のコード変更など）を行う場合は、以下の手順に従ってください：

1. **plans.mdの作成**: 設計ドキュメント（Design Document）として「生きたドキュメント」を作成
2. **exec planの定義**: タスクの詳細な実行計画をplans.mdに記述
3. **段階的な実行**: 計画に従って段階的にタスクを実行
4. **継続的な更新**: 進捗に応じてplans.mdを更新

### exec planの必須要素
- タスクの目的と範囲
- 影響を受けるファイルとディレクトリ
- 各段階でのテスト計画
- リスク評価と対策
- 完了基準の定義

### 計画管理の重要性
**重要**: exec planという用語をモデルにアンカーとして定着させ、大規模なタスク実行時に厳格な計画とテストのループを維持できるようにします。

## Dev environment tips (開発環境のヒント)

### 効率的な開発のためのコマンド
```bash
# 1. 特定のファイルの編集
chezmoi edit ~/.config/fish/config.fish

# 2. 設定の差分確認
chezmoi diff

# 3. 特定のファイルのみ適用
chezmoi apply ~/.config/fish/config.fish

# 4. テンプレート変数の確認
chezmoi data

# 5. ソースディレクトリの確認
chezmoi source-path

# 6. 設定ファイルの検索
chezmoi find "config.fish"

# 7. 管理されているファイルの一覧
chezmoi managed
```

### 新しい設定の追加手順
```bash
# 1. 新しいファイルをchezmoiに追加
chezmoi add ~/.config/newapp/config.toml

# 2. テンプレート化が必要な場合は.tmplにリネーム
mv ~/.local/share/chezmoi/dot_config/newapp/config.toml ~/.local/share/chezmoi/dot_config/newapp/config.toml.tmpl

# 3. テンプレート変数を追加
# 4. テスト実行
chezmoi apply --dry-run
```

### パッケージ管理とワークスペース
```bash
# 1. パッケージの検索とジャンプ
chezmoi find "package_name"

# 2. 設定ファイルの依存関係確認
chezmoi data | jq '.dependencies'

# 3. 環境別設定の確認
chezmoi execute-template --template '{{ .chezmoi.os }}'
```

### デバッグのヒント
```bash
# 1. テンプレートのデバッグ
chezmoi execute-template --template '{{ .chezmoi.os }}'

# 2. 特定の条件の確認
chezmoi execute-template --template '{{ if eq .chezmoi.os "darwin" }}macOS{{ else }}Other{{ end }}'

# 3. 環境変数の確認
chezmoi data | jq '.wsl2'

# 4. 設定の詳細表示
chezmoi status --verbose

# 5. テンプレートの構文チェック
chezmoi execute-template --template '{{ .chezmoi.sourceDir }}'
```

### 視覚的検証の活用
```bash
# 1. 設定ファイルの構文ハイライト表示
chezmoi diff --color=always

# 2. 設定の構造化表示
chezmoi data | jq '.'

# 3. テンプレートのレンダリング結果確認
chezmoi execute-template --template '{{ .chezmoi.sourceDir }}' | head -20
```

### Dockerを使ったテスト環境

#### 全環境のテスト実行
```bash
# 1. 全環境でのテスト実行
docker-compose up -d
docker-compose exec linux-interactive bash -c "./install.sh && chezmoi status"
docker-compose exec wsl2-interactive bash -c "./install.sh && chezmoi status"
docker-compose exec remote-containers-interactive bash -c "./install.sh && chezmoi status"
docker-compose exec codespaces-interactive bash -c "./install.sh && chezmoi status"
docker-compose down
```

#### 個別環境のテスト
```bash
# 1. Linux環境のテスト
docker-compose up -d linux-interactive
docker-compose exec linux-interactive bash -c "./install.sh && chezmoi status"
docker-compose down

# 2. WSL2環境のテスト
docker-compose up -d wsl2-interactive
docker-compose exec wsl2-interactive bash -c "./install.sh && chezmoi status"
docker-compose down

# 3. Remote Containers環境のテスト
docker-compose up -d remote-containers-interactive
docker-compose exec remote-containers-interactive bash -c "./install.sh && chezmoi status"
docker-compose down

# 4. Codespaces環境のテスト
docker-compose up -d codespaces-interactive
docker-compose exec codespaces-interactive bash -c "./install.sh && chezmoi status"
docker-compose down
```

#### デバッグとログ確認
```bash
# 1. インタラクティブなテスト（デバッグ用）
docker-compose exec linux-interactive bash

# 2. 特定のスクリプトのみテスト
docker-compose exec linux-interactive bash -c "
  # パッケージインストールスクリプトのテスト
  bash src/.chezmoiscripts/linux/run_once_before_00_install-packages.sh.tmpl
"

# 3. テスト後のログ確認
docker-compose logs linux-interactive

# 4. コンテナの完全リセット
docker-compose down -v
docker-compose up -d
```

#### 環境変数のテスト
```bash
# 1. REMOTE_CONTAINERSフラグのテスト
docker-compose exec remote-containers-interactive bash -c "
  echo 'REMOTE_CONTAINERS環境での設定:'
  chezmoi data | jq '.remoteContainers, .email, .workspaceRoot, .editor'
"

# 2. CODESPACESフラグのテスト
docker-compose exec codespaces-interactive bash -c "
  echo 'CODESPACES環境での設定:'
  chezmoi data | jq '.codespaces, .email, .workspaceRoot, .editor'
"
```

## Extra instructions (追加の指示)

### コミットメッセージのガイドライン
```
[OS/環境] カテゴリ: 変更内容

例:
[macOS] Fish: 新しいエイリアスを追加
[Linux] Neovim: LSP設定を更新
[共通] chezmoi: テンプレート変数を修正
```

### セキュリティ上の考慮事項
- **機密情報のハードコーディング禁止**: テンプレート変数を使用
- **環境変数の適切な使用**: `env "VARIABLE_NAME"`を使用
- **条件分岐でのセキュリティチェック**: 適切なOS/環境判定

### 新しいチームメイトへの重要な情報
1. **chezmoiの基本概念**: ソースディレクトリ（`src/`）とホームディレクトリの関係
2. **テンプレートシステム**: Goテンプレート構文の理解が必須
3. **OS/環境の判定**: `{{ .chezmoi.os }}`、`{{ .wsl2 }}`等の変数
4. **設定ファイルの依存関係**: パッケージインストールスクリプトの実行順序

### トラブルシューティング
```bash
# 1. 設定が壊れた場合
chezmoi apply --source ~/.local/share/chezmoi.backup

# 2. 特定のファイルの復元
chezmoi apply ~/.config/fish/config.fish

# 3. 完全な再初期化（最終手段）
chezmoi init --apply ispern
```

### 禁止事項
- **テストをパスしないコードのコミット**
- **既存の動作を破壊する変更**
- **テンプレート構文の誤用**
- **機密情報のハードコーディング**
- **OS固有の設定を他のOSに適用**

## モノレポ対応とサブプロジェクト管理

### サブプロジェクトのAGENTS.md
このプロジェクトが大規模なモノレポに発展した場合：
- 各サブプロジェクト（`src/dot_config/fish/`、`src/dot_config/nvim/`等）に個別のAGENTS.mdを配置
- エージェントはディレクトリツリー内で最も近いAGENTS.mdを自動的に読み取り、その指示が優先される
- 各パッケージに合わせたカスタマイズされた指示を含める

### 現在のプロジェクト構造
```
src/
├── dot_config/
│   ├── fish/          # Fish Shell設定
│   ├── nvim/          # Neovim設定
│   └── alacritty/     # Alacritty設定
├── dot_tmux/          # tmux設定とプラグイン
└── dot_zsh/           # Zsh設定
```

## AIエージェント向けの特別指示

### 自動実行されるべきアクション
1. **タスク開始時**: 必ず`chezmoi check`を実行
2. **変更後**: `chezmoi apply --dry-run`で動作確認
3. **コミット前**: 全テストコマンドの実行
4. **エラー発生時**: エラーメッセージの詳細分析と修正

### 一貫性の維持
- 既存のコードスタイルに厳密に従う
- テンプレート構文の正確な使用
- 適切なコメントの配置
- ファイル命名規則の遵守

### 品質保証
- すべての変更にテストを追加/更新
- 複数OSでの動作確認
- 既存の設定との互換性確認
- セキュリティ上の考慮事項の遵守

---

**重要**: このガイドラインに従わない変更は、プロジェクトの安定性と保守性を損なう可能性があります。シニアエンジニアとしての責任を持って、高品質なコードと設定を提供してください。

**AIエージェント向け**: このAGENTS.mdは、Codex、Amp、Jules (Google) など、使用するさまざまなAIコーディングエージェントに対して、一貫性のある明確な作業指示を提供することを目的としています。