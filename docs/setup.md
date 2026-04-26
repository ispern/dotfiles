# セットアップ手順

各 OS で `install.sh` を curl パイプ経由で 1 コマンド実行すると、**Nix インストール → chezmoi インストール → dotfiles 適用 → OS 別 Nix 構成適用** までを自動で行います。

```sh
curl -fsSL https://raw.githubusercontent.com/ispern/dotfiles/main/install.sh | sh
```

OS は `install.sh` 内で `uname` / `/proc/version` / `uname -m` から自動判定されます。

---

## macOS

### 流れ
1. Determinate Systems Installer で Nix を導入（既存ならスキップ）
2. `chezmoi` を導入（`get.chezmoi.io` 経由、既存ならスキップ）
3. `chezmoi init --apply ispern` でリポジトリ取得 + dotfiles 配置
4. `sudo nix run nix-darwin -- switch --flake ./nix#default`
   - CLI ツール (Home Manager) + macOS システム設定 (`system.defaults`) + GUI cask + Font の **すべて** を一括適用
   - 初回のみ sudo パスワードが必要
   - 以降は `darwin-rebuild switch --flake ./nix#default`（sudo 不要）

### 完了後
```sh
chsh -s "$(which fish)"   # fish をデフォルトシェルに
```
- ログアウト/再ログインで `system.defaults` の一部が反映される
- TouchID 対応キーボードがあるなら `security.pam.services.sudo_local.touchIdAuth = true` を追加検討（[architecture.md の Phase 3 セクション](./architecture.md) 参照）

### 確認
```sh
which fish bat eza fd ripgrep tmux nvim git delta zoxide   # Nix 経由で揃うか
brew list --cask | sort                                    # nix/darwin/homebrew.nix と一致するか
defaults read com.apple.dock autohide                      # 1 が返れば system-defaults 適用済
darwin-rebuild --list-generations                          # 世代履歴
```

---

## Linux ネイティブ

### 流れ
1. Determinate Systems Installer で Nix を導入
2. `chezmoi` を導入
3. `chezmoi init --apply ispern`
4. `nix run home-manager/master -- switch --flake ./nix#linux`
   - CLI ツールを Home Manager (standalone) で導入
   - **sudo は不要**（システム改変なし、ユーザプロファイルにインストール）
   - aarch64 ホスト (Apple Silicon Docker, Surface Pro X 等) は自動的に `linux-aarch64` bundle に切替

### 完了後
```sh
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"
```

### 確認
```sh
which fish bat eza fd ripgrep tmux nvim git delta zoxide   # /home/<user>/.nix-profile/bin/ 配下
nix run home-manager -- generations                        # 世代履歴
```

---

## WSL2 (Ubuntu 等)

### 流れ
- Linux ネイティブと同じ 4 ステップ + 以下を自動判定で追加実行:
  - `/proc/version` に `microsoft` を含むかで WSL2 を検出
  - WSL2 検出時: Home Manager bundle として `wsl` (または `wsl-aarch64`) を選択
  - chezmoi スクリプト `src/.chezmoiscripts/linux/wsl/` が:
    - `apt install socat` (1Password ssh-agent ブリッジ用)
    - `~/bin/win32yank.exe` 配置（クリップボード Windows 連携）
    - `~/bin/npiperelay.exe` 配置（SSH エージェント名前付きパイプリレー）
- WSL2 専用 Home Manager パッケージ: `azure-cli`, `awscli2`

### 事前準備（手動）
- Windows 側に 1Password デスクトップアプリをインストール、`Settings > Developer > Use the SSH agent` を ON
- WSL2 内の fish/zsh が起動時に `socat` 経由で Windows パイプにブリッジ（chezmoi の dotfiles テンプレートで自動）

### 完了後
```sh
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"
```

---

## Windows ネイティブ

CLI 開発作業は WSL2 経由を推奨。Windows 側は **GUI アプリ管理のみ** を `winget` で行います。

```powershell
winget import winget.json
```

含まれるアプリ: 7zip, Docker Desktop, Firefox Developer Edition, Git for Windows, Google Chrome, 1Password, Notion, Claude, OBS Studio, AutoHotkey, Volta, Adobe CC 等（詳細は `winget.json`）。

dotfiles 本体は WSL2 内で `chezmoi apply` するため、Windows 側で `chezmoi` を直接動かす必要はありません。

---

## 環境変数フラグ（テスト・開発用）

`install.sh` は以下の環境変数で動作を上書きできます:

| 変数 | 用途 |
|---|---|
| `DOTFILES_REPO=/path/to/local-clone` | ローカルの git リポジトリから chezmoi を初期化（push 不要の検証用） |
| `DOTFILES_BRANCH=feature/xxx` | GitHub 上の特定ブランチから初期化（マージ前の検証用） |
| `DOTFILES_FORCE_WSL=1` | `/proc/version` の microsoft 文字列無しでも WSL2 として扱う（Docker 内検証等） |

## Docker での Linux/WSL2 検証

ホストを汚さずに `install.sh` の動作を確認できます:

```sh
docker compose run --rm linux-interactive   # Linux ネイティブ
docker compose run --rm wsl2-interactive    # WSL2 シミュレート
```

Nix flake 自体のビルドだけ確認するなら:

```sh
docker run --rm -v $(pwd):/workspace -w /workspace nixos/nix \
  nix --extra-experimental-features "nix-command flakes" \
  build ./nix#homeConfigurations.linux.activationPackage --no-link
```

aarch64 (Apple Silicon Docker) は `homeConfigurations.linux-aarch64` に置き換え。

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| `darwin-rebuild` 適用後に UI がおかしい | `darwin-rebuild --rollback` で直前世代へ |
| Linux で `home-manager switch` 後に動作不良 | `nix run home-manager -- generations` から ID 指定で過去世代へ |
| `chezmoi apply` で衝突 | `chezmoi diff` で確認後、`chezmoi apply --force` または個別解消 |
| WSL2 で `1password` ssh-agent が動かない | Windows 側の 1Password で `Use the SSH agent` が有効か、`socat`/`npiperelay.exe` が配置されているか確認 |
