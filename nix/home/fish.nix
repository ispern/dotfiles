{ pkgs, lib, config, ... }:

# Home Manager owns ~/.config/fish/config.fish (generated). The OS-specific
# config files (config-base.fish, config-osx.fish, …) and helper functions
# remain chezmoi-managed; we just source them from the generated config.fish.
{
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
    ];

    shellInit = ''
      set -l fish_config_dir (dirname (status --current-filename))
      source $fish_config_dir/config-base.fish

      switch (uname)
        case Darwin
          source $fish_config_dir/config-osx.fish
        case Linux
          if string match -q "**microsoft**" (uname -r)
            source $fish_config_dir/config-linux-wsl.fish
          end
          source $fish_config_dir/config-linux.fish
      end

      set -l local_config $fish_config_dir/config-local.fish
      test -f $local_config; and source $local_config
    '';
  };
}
