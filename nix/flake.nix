{
  description = "ispern's dotfiles - Nix-managed CLI environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
              home-manager.extraSpecialArgs = { inherit username; isWsl = false; };
              home-manager.users.${username} = import ./home;
              users.users.${username}.home = "/Users/${username}";
            }
          ];
        };

      # Standalone Home Manager 用ヘルパー。Linux ネイティブ / WSL2 のいずれも
      # 共通モジュール (./home) + OS 固有モジュールを合成する。
      mkHome = { system ? "x86_64-linux", isWsl ? false }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username isWsl; };
          modules = [
            ./home
            (if isWsl then ./home/wsl.nix else ./home/linux.nix)
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

      # Standalone Home Manager configurations for Linux / WSL2.
      # Invoked via: nix run home-manager -- switch --flake ./nix#linux (or #wsl)
      # ARM 環境（Apple Silicon Docker / Surface Pro X / Graviton 等）向けに
      # `-aarch64` サフィックス付き bundle も用意。install.sh が自動選択する。
      homeConfigurations."${username}@linux" = mkHome { system = "x86_64-linux"; isWsl = false; };
      homeConfigurations."${username}@linux-aarch64" = mkHome { system = "aarch64-linux"; isWsl = false; };
      homeConfigurations."${username}@wsl" = mkHome { system = "x86_64-linux"; isWsl = true; };
      homeConfigurations."${username}@wsl-aarch64" = mkHome { system = "aarch64-linux"; isWsl = true; };

      # Convenience aliases for username-agnostic invocation in install.sh.
      homeConfigurations.linux = self.homeConfigurations."${username}@linux";
      homeConfigurations.linux-aarch64 = self.homeConfigurations."${username}@linux-aarch64";
      homeConfigurations.wsl = self.homeConfigurations."${username}@wsl";
      homeConfigurations.wsl-aarch64 = self.homeConfigurations."${username}@wsl-aarch64";
    };
}
