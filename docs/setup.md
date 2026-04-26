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

### 既存環境からのクリーン再インストール (Linux / WSL2)

旧 zsh + zinit + Linuxbrew 構成や中途半端な状態から、現行 Nix Flakes 構成に乗り換える場合の手順。`~/.ssh` / `~/.gnupg` / `~/workspace/` 等は **このリポジトリの管理対象外** なので触れません。

#### Step 1: chezmoi 状態を完全削除

```sh
rm -rf ~/.local/share/chezmoi   # ソースリポジトリ clone 先
rm -rf ~/.config/chezmoi        # chezmoi.json / chezmoi.toml 設定
```

#### Step 2: 旧 dotfiles 残骸の削除

```sh
# zsh + zinit 時代の残骸
rm -rf ~/.zinit ~/.zsh ~/.p10k.zsh
rm -f  ~/.zshrc ~/.zsh_history

# 旧 dotfiles を git clone していた場合
rm -rf ~/.dotfiles

# chezmoi が後で正しいテンプレートから作り直すため一旦削除
rm -f ~/.gitconfig ~/.tmux.conf ~/.vimrc

# tmux プラグイン (TPM) 残骸
rm -rf ~/.tmux/plugins ~/.tmux

# 古い fish 設定ディレクトリ (chezmoi が ~/.config/fish/ を再生成する)
rm -rf ~/.config/fish
```

#### Step 3 (任意): Linuxbrew のアンインストール

旧 Notion 手順で Linuxbrew を入れていた場合のみ:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
sudo rm -rf /home/linuxbrew /opt/homebrew ~/.linuxbrew
```

`~/.bashrc` / `~/.profile` から `eval "$(brew shellenv)"` の行も削除。

#### Step 4 (任意): Nix の完全リセット

Nix 自体が壊れている場合のみ。健全なら飛ばす:

```sh
# Determinate Systems Installer 経由なら
/nix/nix-installer uninstall

# Home Manager の旧世代をクリーンアップだけしたい場合
home-manager expire-generations '-1 days'
nix-collect-garbage -d
```

#### Step 5: シェルを bash に戻す（再インストール前の安全策）

```sh
chsh -s /bin/bash
# 一度ログアウト/ログインしてから次のステップへ
```

これで chezmoi が新しい fish 設定を配置する間、シェル不在で詰むのを回避。

#### Step 6: クリーンインストール実行

```sh
curl -fsSL https://raw.githubusercontent.com/ispern/dotfiles/main/install.sh | sh
```

`install.sh` が:
1. Nix 未導入なら Determinate Installer で導入
2. chezmoi 未導入なら導入
3. `chezmoi init --apply ispern` で clean な状態から dotfiles 配置
4. `nix run home-manager/master -- switch --flake ./nix#linux` (or `#wsl`) で CLI を Nix 管理化

#### Step 7: シェルを fish に切替

```sh
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"
```

#### Step 8: 動作確認

```sh
which fish bat eza fd ripgrep tmux nvim git delta zoxide
# → /home/<user>/.nix-profile/bin/ 配下で揃う

nix run home-manager -- generations
# 直近の世代が出れば成功
```

#### ディスク領域の追加クリーンアップ (任意)

```sh
home-manager expire-generations '-7 days'   # 古い HM 世代を削除
nix-collect-garbage -d                      # Nix store の不要 path を全削除
nix-store --optimise                        # Nix store を最適化 (重複ハードリンク化)
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

## Windows

`install.sh` は POSIX shell 依存のため Windows ネイティブ (PowerShell/cmd) では走りません。Windows は **「ネイティブ側 = chezmoi + winget」「WSL2 内 = install.sh で完全構築」の二段構え** になります。

```powershell
# Windows ネイティブ (PowerShell)
winget install twpayne.chezmoi
chezmoi init --apply ispern   # → 内部で winget import winget.json + winget upgrade --all を自動実行
```

```sh
# WSL2 内 (Ubuntu-24.04 等)
curl -fsSL https://raw.githubusercontent.com/ispern/dotfiles/main/install.sh | sh
```

詳細手順 (1Password SSH agent ブリッジ、Wezterm の WSL 既定起動、トラブルシューティング等) は **[`windows.md`](./windows.md) を参照**。

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
