# Neovim キーマップリファレンス

このドキュメントは、このdotfilesプロジェクトで使用しているNeovimのキーマップをまとめたものです。

**注意**: この設定はLazyVimベースです。LazyVimのデフォルトキーマップに加えて、カスタムキーマップが追加されています。

## リーダーキー

- `<leader>` = スペースキー (` `)
- `<localleader>` = カンマ (`,`)

## キーマップ一覧

### バッファナビゲーション

| キー | 説明 |
|------|------|
| `<A-Left>` | 前のバッファに移動 |
| `<A-Right>` | 次のバッファに移動 |
| `gb` | バッファを選択（BufferLinePick） |
| `<leader>d` | 現在のバッファを削除 |

### ファイルエクスプローラー

| キー | 説明 |
|------|------|
| `<a-1>` | Neo-treeのトグル（ファイルエクスプローラーの表示/非表示） |

**注意**: LazyVimではデフォルトで`<leader>e`でファイルエクスプローラーを開きます。`<a-1>`はカスタムキーマップです。

### Telescope（検索・ファイル操作）

| キー | 説明 |
|------|------|
| `<c-p>` | コマンド検索 |
| `<leader>tf` | ファイル検索（隠しファイルを含む） |
| `<leader>tl` | ライブグレップ（テキスト検索、隠しファイルを含む） |
| `<leader>tb` | バッファ一覧 |
| `<leader>tgs` | Gitステータス |
| `<a-2>` | ファイルブラウザー（隠しファイルを含む） |

#### Telescope内での操作

| キー | 説明 |
|------|------|
| `<c-j>` | 次の候補に移動 |
| `<c-k>` | 前の候補に移動 |
| `q` | Telescopeを閉じる |

#### ファイルブラウザー内での操作

| キー | 説明 |
|------|------|
| `<c-n>` | 新しいファイル/ディレクトリを作成 |
| `<c-r>` | リネーム |
| `<c-h>` | 隠しファイルの表示/非表示を切り替え |
| `<c-x>` | 削除 |
| `<c-p>` | 移動 |
| `<c-y>` | コピー |
| `<c-a>` | すべて選択 |

### LSP（Language Server Protocol）

LazyVimのデフォルトLSPキーマップ（カスタム設定で保持）:

| キー | 説明 |
|------|------|
| `K` | ホバー情報を表示（シンボルの詳細情報） |
| `gf` | フォーマット（コード整形） |
| `gr` | 参照を検索（シンボルの使用箇所を検索） |
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gi` | 実装へジャンプ |
| `gt` | 型定義へジャンプ |
| `gn` | リネーム |
| `ga` | コードアクション（利用可能なアクションを表示） |
| `ge` | 診断情報を表示（エラー/警告の詳細） |
| `g]` | 次の診断へ移動 |
| `g[` | 前の診断へ移動 |

**注意**: LazyVimでは`<leader>cr`でインラインリネームが利用可能です（inc-rename.nvim使用時）。

### Git操作

| キー | 説明 |
|------|------|
| `<a-5>` | Neogitを開く（Git操作パネル） |
| `<leader>gb` | Git blameを表示 |
| `<leader>go` | Gitリポジトリでファイル/フォルダを開く |
| `<leader>gg` | LazyGitを開く（Git操作UI） |
| `<leader>gl` | LazyGit: 現在のファイルのGit操作 |
| `<leader>gL` | LazyGit: フィルター付きで開く |
| `<leader>glF` | LazyGit: 現在のファイルでフィルター付き |

### コメント

| キー | 説明 |
|------|------|
| `<C-_>` | 行コメントのトグル（コメントアウト/解除） |

### 補完（CMP - Completion）

| キー | 説明 |
|------|------|
| `<C-Space>` | 補完を開始 |
| `<Tab>` | 次の候補を選択 / スニペットを展開 |
| `<S-Tab>` | 前の候補を選択 / スニペットを戻る |
| `<Enter>` | 選択した候補を確定 |
| `<C-e>` | 補完をキャンセル |
| `<C-b>` | ドキュメントを上にスクロール |
| `<C-f>` | ドキュメントを下にスクロール |

### Tree-sitter（インクリメンタル選択）

| キー | 説明 |
|------|------|
| `gnn` | 選択を開始 |
| `grn` | ノードを拡張（選択範囲を拡大） |
| `grc` | スコープを拡張（親スコープまで拡大） |
| `grm` | ノードを縮小（選択範囲を縮小） |

### Cursor Agent

| キー | 説明 |
|------|------|
| `<leader>ca` | Cursor Agentトグル（AIアシスタントの表示/非表示） |
| `<leader>cA` | バッファ全体をCursor Agentに送信 |
| `<leader>ca` (Visual) | 選択範囲をCursor Agentに送信 |

**注意**: cursor-cliがインストールされている必要があります。インストール方法:
```bash
curl https://cursor.com/install -fsSL | bash
```

### ターミナル

| キー | 説明 |
|------|------|
| `<leader>fT` | ターミナルを開く（現在のディレクトリ） |
| `<leader>ft` | ターミナルを開く（プロジェクトルートディレクトリ） |
| `<c-/>` または `<c-_>` | ターミナルを開く（プロジェクトルートディレクトリ） |

**ターミナル内での操作**:
- `<Esc>`: ノーマルモードに切り替え（ターミナルから抜ける）
- `i`: インサートモードに戻る（ターミナルに戻る）
- `q`: ターミナルを閉じる（非表示）

詳細は`docs/nvim/terminal.md`を参照してください。

### 設定のリロード

| コマンド | 説明 |
|---------|------|
| `:Lazy reload <plugin-name>` | 特定のプラグインをリロード |
| `:Lazy reload` | すべてのプラグインをリロード |
| `:luafile <file-path>` | Luaファイルを再読み込み |
| `:luafile %` | 現在のバッファのファイルを再読み込み |
| `:qa` | Neovimを終了（再起動が必要） |

**例**:
```vim
:Lazy reload snacks.nvim  " snacks.nvimをリロード
:luafile ~/.config/nvim/lua/plugins/snacks.lua  " 設定ファイルを再読み込み
```

詳細は`docs/nvim/reload.md`を参照してください。

### カラースキーム

| 項目 | 説明 |
|------|------|
| **カラースキーム名** | `custom` |
| **パレットファイル** | `lua/colors/palette.lua` |
| **実装ファイル** | `lua/colors/custom.lua` |

**適用方法**:
- Neovim起動時に自動的に適用されます
- 手動で適用する場合: `:lua require("colors.custom").setup()`
- パレットの色を変更する場合: `lua/colors/palette.lua`を編集

詳細は`docs/nvim/colorscheme.md`を参照してください。

## 補足情報

### 補完ソースの優先順位

1. LSPシグネチャヘルプ
2. LSP（Language Server Protocol）
3. LuaSnip（スニペット）
4. Neovim Lua API
5. パス補完
6. バッファ補完

### コマンドライン補完

- `/` (検索): バッファ補完
- `:` (コマンド): パス補完 → コマンド補完

## LazyVimのデフォルトキーマップ

LazyVimには多くのデフォルトキーマップが含まれています。主要なものを以下に示します：

### 一般的な操作

| キー | 説明 |
|------|------|
| `<leader>` | リーダーキー（スペース） |
| `<leader>qq` | 終了 |
| `<leader>qa` | すべて終了 |
| `<leader>w` | 保存 |
| `<leader>wa` | すべて保存 |

### 検索・ナビゲーション

| キー | 説明 |
|------|------|
| `<leader>ff` | ファイル検索（Telescope） |
| `<leader>fg` | ライブグレップ（Telescope） |
| `<leader>fb` | バッファ検索（Telescope） |
| `<leader>fr` | 最近使用したファイル（Telescope） |
| `<leader>e` | ファイルエクスプローラー |

### その他のLazyVim機能

詳細は[LazyVim公式ドキュメント](https://lazyvim.org)を参照してください。

## 参考リンク

- [LazyVim公式サイト](https://lazyvim.org)
- [LazyVim GitHub](https://github.com/LazyVim/LazyVim)
- [cursor-agent.nvim](https://github.com/xTacobaco/cursor-agent.nvim)
- [cursor-cli](https://cursor.com/ja/blog/cli)

