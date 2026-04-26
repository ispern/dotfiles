# Windows セットアップ手順

Windows は **「Windows ネイティブ側 = GUI アプリ + dotfiles 一部」「WSL2 内 = CLI 開発環境のフル構築」の二段構え** で運用します。両方をセットアップすると、Wezterm を Windows 側から起動するだけで自動的に WSL2 内の fish シェルが立ち上がる、という体験になります。

## 全体像

```
Windows ネイティブ                   WSL2 (Ubuntu-24.04)
┌──────────────────────────┐         ┌──────────────────────────┐
│  chezmoi (winget で導入) │         │  install.sh (curl パイプ)│
│    └ winget import       │         │    ├ Determinate Nix     │
│       (winget.json)      │         │    ├ chezmoi             │
│                          │         │    ├ chezmoi apply       │
│  Wezterm (cask of winget)│ ◀────── │    │    └ apt: socat     │
│    └ default_domain =    │ default │    │    └ win32yank.exe  │
│       "WSL:Ubuntu-24.04" │ 起動    │    │    └ npiperelay.exe │
│                          │         │    └ home-manager (#wsl) │
│  1Password               │ ssh     │       (fish + tmux + ...)│
│  ├ SSH agent ON          │ agent   │                          │
│  └ npiperelay 経由でブリッジ ──────►                          │
└──────────────────────────┘         └──────────────────────────┘
```

ポイント:
- **Nix は Windows ネイティブでは使わない**（POSIX 前提のため。詳細は [`architecture.md`](./architecture.md)）
- Windows ネイティブ側は **chezmoi のみ + winget** で最小構成
- 開発作業は **すべて WSL2 内**で完結
- Wezterm は Windows GUI として動くが、シェルは WSL2 内のものを既定で開く

---

## 前提

- Windows 10 22H2 以降 / Windows 11
- WSL2 が利用可能（`wsl --install` で初回有効化）
- 管理者権限のある PowerShell

---

## Step 1: Windows ネイティブ側のセットアップ

### 1-1. chezmoi をインストール

`install.sh` は POSIX shell 依存で **Windows ネイティブ (PowerShell/cmd) では動きません**。chezmoi だけ手動で導入します。

```powershell
winget install twpayne.chezmoi
```

### 1-2. dotfiles 適用 + GUI アプリ一括導入

```powershell
chezmoi init --apply ispern
```

これだけで以下が自動実行されます:

1. `~/.local/share/chezmoi/` にリポジトリ clone
2. Windows 用テンプレート (`{{ if eq .chezmoi.os "windows" }}` 付きファイル) を `C:\Users\<user>\` 以下にレンダリング・配置
   - `~/.gitconfig` の Windows 固有セクション
   - `~/.config/wezterm/wezterm.lua` (OS 判定は Lua 側で実施)
   - `~/.config/alacritty/alacritty.toml` (もし alacritty を使う場合の Windows 固有設定)
3. `src/.chezmoiscripts/windows/run_once_before_00_install-packages.ps1.tmpl` が走る
   - `winget import winget.json` で GUI アプリを一括導入
   - 続けて `winget upgrade --all` で既存アプリを更新

### 1-3. `XDG_CONFIG_HOME` を設定して `~/.config/` を有効化

chezmoi は `src/dot_config/` を `C:\Users\<user>\.config\` に展開しますが、Windows アプリの多くは既定でこのパスを探しません (Neovim は `%LOCALAPPDATA%\nvim\`、Lazygit は `%APPDATA%\lazygit\` を見る)。**`XDG_CONFIG_HOME` 環境変数を設定** すると、各アプリが `~/.config/...` を一括で探すようになります。

#### 方法 A: ユーザ環境変数として恒久設定 (推奨)

PowerShell から 1 行で全プロセス向けに設定:

```powershell
[Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', "$env:USERPROFILE\.config", 'User')
```

- 新しい PowerShell / Wezterm / アプリを起動した瞬間から有効 (再ログイン不要)
- 既存プロセスには反映されない (再起動が必要)
- 確認: `[Environment]::GetEnvironmentVariable('XDG_CONFIG_HOME', 'User')`
- 削除: `[Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $null, 'User')`

GUI からなら `Win + R` → `sysdm.cpl` → 詳細設定 → 環境変数 → ユーザ環境変数 で `XDG_CONFIG_HOME=%USERPROFILE%\.config` を追加。`setx` コマンド (`setx XDG_CONFIG_HOME "%USERPROFILE%\.config"`) も同等。

#### 方法 B: PowerShell プロファイルに追記 (PowerShell セッション内のみ)

PowerShell 起動時に毎回 export したい場合は `$PROFILE` (`$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`) に追記:

```powershell
# プロファイルが無ければ作成
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }

# 追記
Add-Content -Path $PROFILE -Value '$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"'

# 即適用
. $PROFILE
```

- PowerShell セッションを開いた時点で `$env:XDG_CONFIG_HOME` が seed される
- **PowerShell から起動したアプリにのみ伝搬** (Wezterm を Start Menu からダブルクリック起動した場合は伝搬しない → 方法 A が必要)
- PowerShell 7 (`pwsh`) を使う場合は `$HOME\Documents\PowerShell\` 配下、Windows PowerShell 5.1 を使う場合は `$HOME\Documents\WindowsPowerShell\` 配下なので注意

#### 方法 C: 現在のセッションのみ (一時確認用)

```powershell
$env:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"
```

PowerShell ウィンドウを閉じると消える。挙動確認や一時的に試したいときに。

#### 確認

```powershell
echo $env:XDG_CONFIG_HOME           # 現在のセッションでの値
nvim --version | Select-String "config" # Neovim が読む config パスを確認
```

#### 各アプリの挙動

| アプリ | 既定の探索パス (Windows) | `XDG_CONFIG_HOME` 設定後 |
|---|---|---|
| **Wezterm** | `$XDG_CONFIG_HOME/wezterm/`, `~/.config/wezterm/` | 設定不要 — 元から `~/.config/wezterm/` を探す |
| **Neovim** | `%LOCALAPPDATA%\nvim\` | `$XDG_CONFIG_HOME/nvim/` を読むようになる |
| **Lazygit** | `%APPDATA%\lazygit\config.yml` | `$XDG_CONFIG_HOME/lazygit/config.yml` を読む |
| **Starship** | `~/.config/starship.toml` | 設定不要 |
| **Git** (`~/.gitconfig`) | `%USERPROFILE%\.gitconfig` | 設定不要 (Git for Windows が `~` を解決) |

#### `XDG_CONFIG_HOME` を使わない代替: シンボリックリンク

環境変数を増やしたくない場合は、アプリ別にシンボリックリンクを張る選択肢もあります (管理者 PowerShell or Windows の Developer Mode 必須):

```powershell
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$env:USERPROFILE\.config\nvim"
```

ただし対象アプリ分のリンクを作る必要があるので、`XDG_CONFIG_HOME` を 1 つ設定するほうが運用は楽です。

### 1-4. 導入される GUI アプリ (`winget.json`)

| カテゴリ | アプリ |
|---|---|
| 開発 | Docker Desktop / Git for Windows / Volta |
| ターミナル | （Wezterm は cask 経由ではなく winget.json に含めるか別途インストール） |
| ブラウザ | Google Chrome / Firefox Developer Edition |
| 認証 | 1Password |
| ノート / 生産性 | Notion / Canva |
| メディア | OBS Studio / Adobe Creative Cloud |
| ユーティリティ | 7zip / AutoHotkey / Logitech Options+ / VIA |
| AI | Claude |

完全なリストは `winget.json` 参照。

### 1-5. 1Password の SSH agent を有効化

1Password デスクトップアプリを起動 → `Settings > Developer > Use the SSH agent` を ON にします。これで Windows 側に名前付きパイプ `\\.\pipe\openssh-ssh-agent` が公開され、WSL2 内から `npiperelay.exe` 経由で SSH agent をブリッジできます。

---

## Step 2: WSL2 のセットアップ

### 2-1. WSL2 + Ubuntu のインストール

```powershell
wsl --install -d Ubuntu-24.04
```

> ⚠️ ディストリ名に注意: `src/dot_config/wezterm/wezterm.lua` で `default_domain = "WSL:Ubuntu-24.04"` がハードコードされています。別ディストリ名を使う場合は、Wezterm 起動時にエラーになるため、後述の「ディストリ名を変えたい場合」を参照。

WSL2 が起動したら一度シェルに入って初回ユーザを作成します。

### 2-2. dotfiles 一括セットアップ (WSL2 シェル内で)

```sh
curl -fsSL https://raw.githubusercontent.com/ispern/dotfiles/main/install.sh | sh
```

これで `install.sh` が以下を順に行います:

1. Determinate Systems Installer で Nix を導入
2. chezmoi を導入
3. `chezmoi init --apply ispern` で dotfiles 配置
   - `apt install socat` (`run_once_before_05_install-apt.sh.tmpl`)
   - `~/bin/win32yank.exe` 配置 (`run_once_before_06_*`)
   - `~/bin/npiperelay.exe` 配置 (`run_once_before_07_*`)
4. `nix run home-manager/master -- switch --flake ./nix#wsl`
   - fish, tmux, neovim, eza, ripgrep, gh, jq 等の CLI を Nix で導入
   - WSL2 専用パッケージ: `azure-cli`, `awscli2`

### 2-3. fish をデフォルトシェルに

```sh
echo "$(which fish)" | sudo tee -a /etc/shells
chsh -s "$(which fish)"
```

### 2-4. SSH agent ブリッジの確認

WSL2 内で fish を起動して以下を確認:

```fish
echo $SSH_AUTH_SOCK
# → /run/user/<uid>/ssh-agent.sock 等が出る
ssh-add -l
# → 1Password に登録した SSH 鍵が一覧表示されれば OK
```

---

## Step 3: 動作確認

Windows 側から **Wezterm を起動** すると、設定の `default_domain = "WSL:Ubuntu-24.04"` により自動的に WSL2 の Ubuntu-24.04 シェルが開きます。fish プロンプトが表示されれば二段構え完成です。

```
$ which fish bat eza fd ripgrep tmux nvim git delta zoxide
$ tmux           # tmux 起動
$ ssh github.com # 1Password の SSH 鍵で認証できる
```

---

## ディストリ名を変えたい場合

`src/dot_config/wezterm/wezterm.lua` の以下の行を編集します:

```lua
config.default_domain = "WSL:Ubuntu-24.04"
```

別ディストリ名 (`Ubuntu`, `Debian`, `Ubuntu-22.04` 等) を使う場合は、この値を書き換えて `chezmoi apply` で反映してください。複数の Windows マシンで運用するなら chezmoi テンプレート化 (`{{ .wslDistro }}` 変数を `.chezmoi.json.tmpl` に追加) する余地があります。

---

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| Wezterm 起動時に "WSL:Ubuntu-24.04 not found" | WSL2 ディストリ名を確認 (`wsl -l -v`)、`wezterm.lua` の `default_domain` を実際のディストリ名に書き換える |
| `winget import` で一部パッケージが失敗 | パッケージ ID が陳腐化している可能性。`winget.json` を `winget search` で確認して更新 |
| WSL2 内で `ssh-add -l` が "Could not open a connection" | Windows 側 1Password の SSH agent 設定 ON、`~/bin/npiperelay.exe` の存在、socat の起動状態を確認。fish 設定 (`config-linux-wsl.fish`) で `SSH_AUTH_SOCK` 設定が走っているかも要確認 |
| Wezterm のフォントが豆腐 | UDEV Gothic NF が winget で導入されていない。HackGen / JetBrains Mono Nerd 系を Windows 側に手動インストール (winget 不可なら GitHub Releases 等から) |
| chezmoi が Linux/macOS 用の `dot_config/fish/` 等を Windows に配置しようとする | `src/.chezmoiignore` で OS 別に除外設定済み (`{{- if eq .chezmoi.os "windows" }}` セクション)。意図せず配置される場合はこのファイルを確認 |

---

## なぜ二段構えにするか

- **Nix が Windows ネイティブで動かない** ([詳細](./architecture.md)) → CLI 開発環境を Windows 上で再現できない
- **WSL2 = 公式 Linux** → Nix が完全に動き、macOS/Linux と同一の `flake.lock` で再現性が保てる
- **Windows ネイティブの GUI** (Wezterm, Chrome, 1Password 等) と **WSL2 の CLI** をブリッジ (SSH agent / クリップボード / パス) すれば、両方の利点を享受できる

つまり Windows ユーザは「Windows GUI 体験 + Linux CLI 体験」をハイブリッドで得る形になります。CLI 環境については macOS/Linux ネイティブと完全に同一の Nix 構成なので、開発上の差はほぼゼロです。

---

## 関連ドキュメント

- [setup.md](./setup.md) — 全 OS 共通のセットアップフロー概要
- [architecture.md](./architecture.md) — Nix + chezmoi + winget の責務分担、Nix が Windows ネイティブで使えない理由
- [stack.md](./stack.md) — Windows / WSL2 で導入されるソフトウェア一覧
