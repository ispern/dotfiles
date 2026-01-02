# Keymapping リファレンス

このドキュメントは、Wezterm、Fish Shell、Neovimのキーマッピングをまとめたものです。

## 目次

- [Wezterm](#wezterm)
- [Fish Shell](#fish-shell)
- [Neovim](#neovim)

---

## Wezterm

### リーダーキー

- **リーダー**: `Ctrl+G` (タイムアウト: 2000ms)

### Workspace操作

| キー | 説明 |
|------|------|
| `Leader w` | ワークスペース切り替え |
| `Leader ,` | ワークスペース名変更 |
| `Leader+Shift W` | 新しいワークスペース作成 |

### Tab操作

| キー | 説明 |
|------|------|
| `Ctrl+Tab` | 次のタブ |
| `Ctrl+Shift+Tab` | 前のタブ |
| `Leader {` | タブを左に移動 |
| `Leader }` | タブを右に移動 |
| `Leader c` | 新しいタブ作成 |
| `Ctrl+W` | タブを閉じる（確認付き） |

### Pane操作

| キー | 説明 |
|------|------|
| `Leader -` | 縦分割 |
| `Leader \|` | 横分割 |
| `Leader x` | ペインを閉じる（確認付き） |
| `Leader h` | 左のペインに移動 |
| `Leader l` | 右のペインに移動 |
| `Leader k` | 上のペインに移動 |
| `Leader j` | 下のペインに移動 |
| `Ctrl+Shift+[` | ペイン選択モード |
| `Leader z` | 選択中のペインのみ表示（ズーム） |

### コピーモード

| キー | 説明 |
|------|------|
| `Leader [` | コピーモードに入る |
| `Ctrl+V` | クリップボードから貼り付け |

### コピーモード内の操作

#### 移動

| キー | 説明 |
|------|------|
| `h` / `j` / `k` / `l` | カーソル移動 |
| `^` | 行の先頭（コンテンツ） |
| `$` | 行の末尾（コンテンツ） |
| `0` | 行の左端 |
| `w` / `b` / `e` | 単語単位で移動 |
| `g` | スクロールバッファの先頭 |
| `G` | スクロールバッファの末尾 |
| `H` / `M` / `L` | ビューポートの上/中/下 |

#### ジャンプ

| キー | 説明 |
|------|------|
| `t` / `f` | 前方ジャンプ（次/現在の文字） |
| `T` / `F` | 後方ジャンプ（次/現在の文字） |
| `;` | 前回のジャンプを繰り返し |

#### スクロール

| キー | 説明 |
|------|------|
| `Ctrl+B` | ページアップ |
| `Ctrl+F` | ページダウン |
| `Ctrl+D` | 半ページダウン |
| `Ctrl+U` | 半ページアップ |

#### 選択

| キー | 説明 |
|------|------|
| `v` | セル選択モード |
| `Ctrl+V` | ブロック選択モード |
| `V` | 行選択モード |
| `o` / `O` | 選択の反対端に移動 |

#### コピーと終了

| キー | 説明 |
|------|------|
| `y` | クリップボードにコピー |
| `Enter` | コピーして終了 |
| `Escape` / `Ctrl+C` / `Ctrl+]` / `q` | コピーモードを終了 |

### ペインサイズ調整 (Leader + s)

| キー | 説明 |
|------|------|
| `h` / `l` / `k` / `j` | ペインサイズを調整 |
| `Enter` | モードを終了 |

### その他

| キー | 説明 |
|------|------|
| `Leader p` | コマンドパレット |
| `Ctrl+Shift+P` | コマンドパレット |
| `Alt+Enter` | フルスクリーン切り替え |
| `Ctrl++` | フォントサイズを大きく |
| `Ctrl+-` | フォントサイズを小さく |
| `Ctrl+0` | フォントサイズをリセット |
| `Ctrl+Shift+R` | 設定を再読み込み |

**設定ファイル**: `src/dot_config/wezterm/keybindings.lua`

---

## Fish Shell

### 基本設定

- **VIモード**: `fish_vi_key_bindings` を使用

### FZF統合

| キー | 説明 |
|------|------|
| `Ctrl+F f` | ファイル検索 (`fzf_find_file`) |
| `Ctrl+F d` | ディレクトリ移動 (`fzf_change_directory`) |
| `Ctrl+R` | コマンド履歴検索 (`fzf_search_history`) |

### GitHub関連

| キー | 説明 |
|------|------|
| `Ctrl+F i` | GitHub Issue検索 (`fzf_gh_issue`) |
| `Ctrl+F r` | ghqリポジトリ検索 (`fzf_ghq_search_repository`) |

### tmux関連

| キー | 説明 |
|------|------|
| `Ctrl+F t` | tmuxセッション一覧 (`fzf_tmux_list`) |
| `Ctrl+F k` | tmuxセッション削除 (`fzf_tmux_kill_session`) |

### SSH関連

| キー | 説明 |
|------|------|
| `Ctrl+F s` | SSHホスト検索 (`fzf_search_ssh_host`) |

### Git Worktree関連

| キー | 説明 |
|------|------|
| `Ctrl+F w` | Git worktree切り替え (`fzf_git_worktree`) |
| `Ctrl+F w a` | Git worktree追加 (`fzf_git_worktree_add`) |

**設定ファイル**: `src/dot_config/fish/functions/fish_user_key_bindings.fish`

---

## Neovim

### リーダーキー

- **リーダー**: `<leader>` = スペースキー (` `)
- **ローカルリーダー**: `<localleader>` = カンマ (`,`)

**設定ファイル**: `src/dot_config/nvim/lua/config/keymaps.lua`

---

## 補足情報

### 共通パターン

- **リーダー/プレフィックス**: WeztermとFish Shellで `Ctrl+G` / `Ctrl+F` を使用
- **VIモード**: Fish ShellでVIモードを有効化
- **FZF統合**: Fish Shellで `Ctrl+F` プレフィックスを使用

### 更新履歴

このドキュメントは、設定ファイルの変更に応じて更新されます。
