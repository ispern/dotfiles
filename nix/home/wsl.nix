{ pkgs, lib, ... }:

# WSL2 専用の Home Manager 追加。
# - azure-cli / awscli2 は旧 chezmoiscripts/linux/wsl/run_once_before_03/04 の置き換え。
# - クリップボード連携には Windows 側の win32yank.exe を使うため xclip 不要。
# - 1Password ssh-agent の socat は apt 側で残す（chezmoiscripts/...05_install-apt）。
{
  home.packages = with pkgs; [
    azure-cli
    awscli2
  ];
}
