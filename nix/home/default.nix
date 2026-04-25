{ pkgs, lib, username, ... }:

{
  imports = [
    ./darwin.nix
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
  ] ++ (with pkgs.bat-extras; [
    batdiff
    batgrep
    batman
    batpipe
    batwatch
    prettybat
  ]);

  # Lightweight programs.* enables that don't conflict with chezmoi-managed
  # fish/tmux config files. Fish/tmux config and plugin migration is deferred
  # to a Phase 1.x follow-up PR.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd" "z" ];
  };

  # Let Home Manager track itself
  programs.home-manager.enable = true;
}
