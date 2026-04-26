{ pkgs, lib, username, ... }:

{
  imports = [
    ./darwin.nix
    ./fish.nix
    ./tmux.nix
  ];

  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Pin to the version Home Manager was set up against.
  # Bumping requires reading the release notes for breaking changes.
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Bootstrap / dotfiles
    chezmoi

    # Core CLI
    act
    bat
    curlie
    deno
    eza
    fd
    gh
    ghq
    gibo
    git
    delta
    jq
    neovim
    ripgrep
    tig
    tmux

    # Shell
    fish

    # Utilities
    wget
    tree
    htop
    ncdu
    tldr
    glow
    yq

    # Network / misc
    iperf3

    # OpenAPI codegen (v3)
    swagger-codegen3

    # Prompt (programs.starship.enable injects init for fish/zsh below)
    starship

    # Fuzzy finder (programs.fzf.enable wires shell integration)
    fzf
  ] ++ (with pkgs.bat-extras; [
    batdiff
    batgrep
    batman
    batpipe
    batwatch
    prettybat
  ]);

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd" "z" ];
  };

  # Auto-injects `starship init fish | source` into config.fish, replacing
  # the equivalent block previously in chezmoi's config-osx.fish.
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Sets FZF_* env vars and shell integrations (Ctrl-R history search etc.).
  # Existing user customizations in chezmoi's config-osx.fish (FZF_DEFAULT_*)
  # take precedence because they are sourced after HM-generated config.fish.
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # Let Home Manager track itself
  programs.home-manager.enable = true;

  # darwin-rebuild の最後に chezmoi apply を自動実行して、Nix 管理 (CLI /
  # programs.*) と chezmoi 管理 (~/.config/* 等の dotfiles) を 1 コマンドで
  # 同期させる。chezmoi 設定がまだ無い初回 bootstrap では skip する。
  home.activation.chezmoiApply =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "$HOME/.config/chezmoi/chezmoi.json" ] \
         || [ -f "$HOME/.config/chezmoi/chezmoi.toml" ] \
         || [ -d "$HOME/.local/share/chezmoi" ]; then
        run --quiet ${pkgs.chezmoi}/bin/chezmoi apply --force \
          || verboseEcho "chezmoi apply failed (non-fatal)"
      fi
    '';
}
