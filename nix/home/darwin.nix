{ pkgs, lib, ... }:

{
  # macOS-specific Home Manager additions.
  # GNU userland tools shadow BSD coreutils so command behavior matches Linux.
  home.packages = lib.mkIf pkgs.stdenv.isDarwin (with pkgs; [
    coreutils
    gnused
    gawk
    findutils
    gnugrep
    procps   # provides `watch`
  ]);
}
