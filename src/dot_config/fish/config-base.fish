set fish_greeting ""

# theme
set -g theme_color_scheme dracula-pro-buffy
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

export XDG_CONFIG_HOME=$HOME/.config

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll 'ls -ltraGvF'
command -qv nvim && alias vim nvim

set -gx EDITOR nvim

alias vi="nvim"

# tmux
alias tm 'tmux'
alias tma 'tmux attach'
alias tmd 'tmux dettach'
alias tml 'tmux list-window'

# git
alias g git

# docker
alias d 'docker'
alias dc 'docker-compose'

# abbr
abbr -a abe 'for a in (abbr --list); abbr --erase $a; end'
abbr -a fr "source ~/.config/fish/config.fish"

if type -q exa
  alias ll "exa -l -g -a --icons --sort=type"
end
