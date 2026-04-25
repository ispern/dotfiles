dotfiles
========

複数のマシンにまたがる個人用設定を **chezmoi + Nix Flakes** で宣言的に管理するためのリポジトリ。

## 環境マトリクス

| 環境 | パッケージ管理 | 設定ファイル |
|---|---|---|
| **macOS** | Nix (nix-darwin + Home Manager) — CLI<br>Homebrew — GUI cask + Font | chezmoi |
| **Linux / WSL** | Nix (Home Manager standalone) — CLI<br>apt — システム依存のみ（Phase 2 予定） | chezmoi |
| **Windows ネイティブ** | winget | chezmoi |

サプライチェーン耐性のため CLI ツールは `flake.lock` でハッシュ固定。GUI アプリは macOS App Store / Homebrew cask で管理し、宣言化は将来の課題（Phase 3）。

## ディレクトリ構成

```
.
├── nix/              # Nix Flakes (CLI 管理) — chezmoi 管理対象外
│   ├── flake.nix
│   ├── home/         # Home Manager
│   └── darwin/       # nix-darwin (macOS only)
├── src/              # chezmoi ソース (.chezmoiroot で指定)
│   ├── dot_config/   # → ~/.config/
│   ├── dot_*.tmpl    # マシン固有値を含むテンプレート
│   └── .chezmoiscripts/
├── Brewfile.darwin   # macOS GUI cask + Font
└── winget.json       # Windows パッケージ
```

## 初回セットアップ

### macOS

1. **Nix のインストール** (Determinate Systems Installer)

    ```sh
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    ```

2. **このリポジトリを clone**

    ```sh
    git clone git@github.com:ispern/dotfiles.git ~/workspace/github.com/ispern/dotfiles
    cd ~/workspace/github.com/ispern/dotfiles
    ```

3. **nix-darwin で CLI 環境をセットアップ**

    ```sh
    sudo nix run nix-darwin -- switch --flake ./nix#default
    ```

    詳細・更新手順は [`nix/README.md`](./nix/README.md)。

4. **GUI アプリ / Font を Homebrew で導入**

    ```sh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle --file=Brewfile.darwin
    ```

5. **chezmoi で dotfiles を適用**

    ```sh
    nix profile install nixpkgs#chezmoi
    chezmoi init --apply git@github.com:ispern/dotfiles.git
    ```

6. **fish をデフォルトシェルに**（`programs.fish.enable` が `/etc/shells` に追加済み）

    ```sh
    chsh -s "$(which fish)"
    ```

### Windows

`winget import winget.json` で一括インストール。dotfiles 本体は WSL2 経由で chezmoi 適用。

### Linux / WSL2

Phase 2 で Nix Flakes 化予定。現状は chezmoi のスクリプトが apt + linuxbrew + 個別バイナリで bootstrap する。

## 移行ステータス

- [x] **Phase 1**: macOS CLI を Nix へ移行
- [ ] **Phase 1.x**: fish プラグイン (fisher → `programs.fish.plugins`)、tmux プラグイン (TPM → `programs.tmux.plugins`) を Home Manager 管理に移行
- [ ] **Phase 2**: Linux / WSL の CLI を Nix へ移行
- [ ] **Phase 3**: macOS システム設定 (`defaults write`) と GUI cask を nix-darwin で宣言化

## ライセンス

このリポジトリ内の自作スクリプトは MIT ライセンス。サードパーティのプラグイン（`src/dot_tmux/plugins/` 等）は各々のライセンスに従う。
