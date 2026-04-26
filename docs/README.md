# docs/

このディレクトリは `ispern/dotfiles` の **内部ドキュメント** を格納します。リポジトリのトップレベル `README.md` はクイックスタート、ここはより詳細な参照資料という位置付けです。

## 一覧

| ドキュメント | 内容 |
|---|---|
| [setup.md](./setup.md) | OS 別セットアップ手順（macOS / Linux ネイティブ / WSL2 / Windows）。`install.sh` の挙動と環境変数フラグの解説 |
| [windows.md](./windows.md) | Windows 専用の二段構えセットアップ詳細（ネイティブ chezmoi + WSL2 内 install.sh、SSH agent ブリッジ、Wezterm の WSL 既定起動） |
| [architecture.md](./architecture.md) | 仕組み・責務分担（Nix Flakes + chezmoi + Homebrew/winget のハイブリッド設計）。OS 別の実行フローと差分 |
| [stack.md](./stack.md) | 採用しているソフトウェア・ライブラリの全体マップ（カテゴリ別、各 OS でのインストール経路明記） |
| [keymapping.md](./keymapping.md) | Wezterm / Fish Shell / Neovim のキーマップ・リファレンス |

## このリポジトリの使い始め方

1. **手早く動かしたい** → トップレベル [`README.md`](../README.md) のワンライナー
2. **何が起きているか理解したい** → [`architecture.md`](./architecture.md)
3. **何が入るのか知りたい** → [`stack.md`](./stack.md)
4. **OS 別の細かい違いを知りたい** → [`setup.md`](./setup.md) と [`architecture.md`](./architecture.md) の OS 別セクション
