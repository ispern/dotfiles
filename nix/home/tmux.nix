{ pkgs, lib, ... }:

# tmux configuration ported from chezmoi-managed src/dot_tmux.conf.tmpl.
# Plugins move from TPM (chezmoi-cloned src/dot_tmux/plugins/*) to
# programs.tmux.plugins, which uses Nix-built tmuxPlugins.* derivations.
{
  programs.tmux = {
    enable = true;

    # Required so the prefix declaration below is the source of truth.
    # `disableConfirmationPrompt = false` keeps the original `confirm-before` binds.
    baseIndex = 0;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      continuum
      cpu
      pain-control
      nord
    ];

    extraConfig = ''
      set-environment -gu RBENV_VERSION

      ## global
      set-window-option -g mode-keys vi
      set-window-option -g automatic-rename off
      set-window-option -g main-pane-height 35
      set-window-option -g monitor-activity on
      set-window-option -g visual-activity on

      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set-option -g default-shell ${pkgs.fish}/bin/fish
      set-option -g default-command ${pkgs.fish}/bin/fish
      set-option -g history-limit 10000
      set-option -g mouse on

      ## Key-bind
      # Set the prefix to ^g.
      unbind ^b
      set -g prefix ^g
      bind-key ^g send-prefix

      # screen ^C c
      unbind ^C
      bind ^C new-window -n zsh
      bind c new-window -n zsh

      # detach ^D d
      unbind ^D
      bind ^D detach

      # displays *
      unbind *
      bind * list-clients

      # next ^@ ^N sp n
      unbind ^@
      bind ^@ next-window
      unbind ^N
      bind ^N next-window
      unbind " "
      bind " " next-window
      unbind n
      bind n next-window

      # title A
      unbind A
      bind A command-prompt "rename-window %%"

      # other ^A
      unbind ^A
      bind ^A last-window

      # prev ^H ^P p ^?
      unbind BSpace
      bind BSpace previous-window

      # windows ^W w
      unbind ^W
      bind ^W list-windows
      unbind w
      bind w list-windows

      # quit \
      unbind \
      bind \ confirm-before "kill-server"

      # kill K
      unbind k
      bind x kill-pane
      bind X kill-window
      bind C-x confirm-before -p "kill other windows? (y/n)" "kill-window -a"
      bind Q confirm-before -p "kill-session #S? (y/n)" kill-session

      # redisplay ^R r
      unbind ^R
      bind ^R refresh-client

      # split -v |
      unbind |
      bind | split-window

      # :kB: focus up
      unbind Tab
      bind Tab select-pane -t :.-
      unbind BTab
      bind BTab select-pane -t :.+
      unbind ^H
      bind ^H select-pane -t :.-
      unbind h
      bind ^h select-pane -t :.-
      unbind ^L
      bind ^L select-pane -t :.+
      unbind l
      bind l select-pane -t :.+

      # " windowlist -b
      unbind '"'
      bind '"' choose-window

      # copy-mode ^[
      unbind ^[
      bind -r ^"[" copy-mode
      unbind ^]
      bind -r ^] paste-buffer
      bind -T copy-mode-vi v send-keys -X begin-selection

      # OS-specific clipboard integration
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        # macOS clipboard integration
        bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
      ''}
      ${lib.optionalString pkgs.stdenv.isLinux ''
        # Linux clipboard integration (xclip)
        bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
      ''}

      # s(split)
      bind-key s display-panes\; command-prompt -p "Window #: " "swap-pane -t '%%'"
      bind-key v display-panes\; split-window -h
      bind-key h display-panes\; split-window -v

      # select-pane
      bind-key -r i select-pane -U
      bind-key -r C-i select-pane -U
      bind-key -r k select-pane -D
      bind-key -r C-k select-pane -D
      bind-key -r j select-pane -L
      bind-key -r C-j select-pane -L
      bind-key -r l select-pane -R
      bind-key -r C-l select-pane -R

      ## resize-pane
      bind-key -r K resize-pane -U
      bind-key -r J resize-pane -D
      bind-key -r L resize-pane -L
      bind-key -r H resize-pane -R

      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Reload Config!!"
    '';
  };
}
