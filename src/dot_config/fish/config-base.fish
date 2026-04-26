set fish_greeting ""

# プロンプトは Starship に集約 (programs.starship.enable で init 注入済み)。
# bobthefish 時代の theme_* 変数 (dracula-pro-buffy 等) は撤去。

set -gx XDG_CONFIG_HOME $HOME/.config

# Locale (formerly in ~/.zshenv)
set -gx LANGUAGE ja_JP.UTF-8
set -gx LANG $LANGUAGE
set -gx LC_ALL en_US.UTF-8
set -gx LC_CTYPE $LANGUAGE

# Editor (single source of truth; OS files may layer on)
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx CVSEDITOR $EDITOR
set -gx SVN_EDITOR $EDITOR
set -gx GIT_EDITOR $EDITOR

# Pager (formerly in ~/.zshenv)
set -gx PAGER less
set -gx LESS '-R -f -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]'
set -gx LESSCHARSET utf-8

# LESS man page colors
set -gx LESS_TERMCAP_mb \e'[01;31m'
set -gx LESS_TERMCAP_md \e'[01;31m'
set -gx LESS_TERMCAP_me \e'[0m'
set -gx LESS_TERMCAP_se \e'[0m'
set -gx LESS_TERMCAP_so \e'[00;44;37m'
set -gx LESS_TERMCAP_ue \e'[0m'
set -gx LESS_TERMCAP_us \e'[01;32m'

# fzf user defaults (programs.fzf.enable provides the base init)
set -gx FZF_DEFAULT_OPTS '--extended --ansi --multi'

# User binaries (highest priority)
fish_add_path -gP $HOME/bin
fish_add_path -gP $HOME/.local/bin

# volta (per-project node tooling — kept opt-in)
if test -d $HOME/.volta
    set -gx VOLTA_HOME $HOME/.volta
    fish_add_path -gP $VOLTA_HOME/bin
end

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll 'ls -ltraGvF'
command -qv nvim && alias vim nvim

alias vi="nvim"

# tmux
alias tm tmux
alias tma 'tmux attach'
alias tmd 'tmux dettach'
alias tml 'tmux list-window'

# git
alias g git

# docker
alias d docker
alias dc docker-compose

# abbr
abbr -a abe 'for a in (abbr --list); abbr --erase $a; end'
abbr -a fr "source ~/.config/fish/config.fish"

if type -q eza
  alias ll "eza -l -g -a --icons --sort=type"
end
