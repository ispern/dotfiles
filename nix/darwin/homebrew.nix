{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    global = {
      brewfile = true;
      lockfiles = false;
    };

    taps = [];

    casks = [
      "1password"
      "1password-cli"
      "atok"
      "chatgpt"
      "claude"
      "cursor"
      "deepl"
      "dropbox"
      "figma"
      "google-chrome"
      "google-drive"
      "jetbrains-toolbox"
      "karabiner-elements"
      "logi-options+"
      "microsoft-auto-update"
      "microsoft-edge"
      "microsoft-office-businesspro"
      "notion"
      "notion-calendar"
      "obsidian"
      "orbstack"
      "path-finder"
      "postman"
      "raycast"
      "slack"
      "visual-studio-code"
      "wezterm@nightly"
      "zoom"

      # Fonts
      "font-hackgen"
      "font-hackgen-nerd"
      "font-jetbrains-mono"
      "font-jetbrains-mono-nerd-font"
      "font-udev-gothic"
      "font-udev-gothic-hs"
      "font-udev-gothic-nf"
    ];
  };
}
