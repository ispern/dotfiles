{ pkgs, lib, ... }:

{
  # macOS-specific Home Manager additions.
  # GNU userland tools shadow BSD coreutils so command behavior matches Linux.
  home.packages = lib.mkIf pkgs.stdenv.isDarwin (with pkgs; [
    coreutils
    gnu-sed
    gawk
    findutils
    gnugrep
    procps   # provides `watch`
  ]);
}
