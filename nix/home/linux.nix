{ pkgs, lib, ... }:

{
  home.packages = lib.mkIf pkgs.stdenv.isLinux (with pkgs; [
    xclip
    wl-clipboard
  ]);
}
