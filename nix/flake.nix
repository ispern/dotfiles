{
  description = "ispern's dotfiles - Nix-managed CLI environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      username = "h.matsuoka";

      mkDarwin = { hostname, system ? "aarch64-darwin" }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit username hostname inputs; };
          modules = [
            ./darwin
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit username; };
              home-manager.users.${username} = import ./home;
              users.users.${username}.home = "/Users/${username}";
            }
          ];
        };
    in
    {
      darwinConfigurations."ispern-mac-mini" = mkDarwin {
        hostname = "ispern-mac-mini";
      };

      # Convenience alias for hostname-agnostic invocation:
      #   darwin-rebuild switch --flake .#default
      darwinConfigurations.default = self.darwinConfigurations."ispern-mac-mini";
    };
}
