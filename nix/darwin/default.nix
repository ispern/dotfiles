{ pkgs, lib, username, hostname, ... }:

{
  # The Nix daemon is managed by the Determinate Systems Installer, so let
  # nix-darwin coexist without re-bootstrapping it.
  nix.enable = false;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Make fish a recognized login shell so `chsh -s fish` succeeds.
  programs.fish.enable = true;

  # Primary user — required for nix-darwin to set up Spotlight launchers and
  # user-scoped services correctly.
  system.primaryUser = username;

  # nix-darwin schema version. Do not change without consulting the release
  # notes: https://github.com/LnL7/nix-darwin/blob/master/CHANGELOG
  system.stateVersion = 5;

  networking.localHostName = hostname;
}
