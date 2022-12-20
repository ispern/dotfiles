# Global
export ZPLUG_HOME=/usr/local/opt/zplug
export TERM="xterm-256color"
export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:~/bin/:$PATH
export PATH=$HOME/Library/Python/3.7/bin/:$PATH
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
export SHELL=/usr/local/bin/zsh

export XDG_CONFIG_HOME=$HOME/.config

# Java
export JAVA_OPTS="-server -Xms1024M -Xmx2048M -Xss3m"
export _JAVA_OPTIONS="-Xms1024M -Xmx2048M -Xss3m -Dfile.encoding=UTF-8"
export JAVA_OPTS="-server -Xms1024M -Xmx2048M -Xss3m"
export _JAVA_OPTIONS="-Xms1024M -Xmx2048M -Xss3m -Dfile.encoding=UTF-8"
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export SBT_OPTS="-server -Xms1024M -Xmx2048M -Xss3m"

# nodebrew
if [ -e $HOME/.nodebrew ]; then
    export PATH=$HOME/.nodebrew/current/bin:$PATH
    nodebrew use v10.16.0
fi

# rbenv
if [ -e $HOME/.rbenv ]; then
    export PATH=$HOME/.rbenv/bin:$PATH
    export PATH=$HOME/.rbenv/shims:$PATH
    eval "$(rbenv init - zsh)"
fi

export STARSHIP_CONFIG=~/.dotfiles/starship.toml

eval "$(starship init zsh)"

# anyframe
zstyle ":anyframe:selector:" use fzf-tmux

# ghq
source /usr/local/share/zsh/site-functions

# alias
alias brew="env PATH=${PATH/\/Users\/hiromitsu\/\.phpenv\/shims:/} brew"
alias rm_ds="find . -name '.DS_Store' -print -exec rm -r {} ';' ; find . -name ._* -exec rm -r {} ";

# hyper
# Override auto-title when static titles are desired ($ title My new title)
title() { export TITLE_OVERRIDDEN=1; echo -en "\e]0;$*\a"}
# Turn off static titles ($ autotitle)
autotitle() { export TITLE_OVERRIDDEN=0 }; autotitle
# Condition checking if title is overridden
overridden() { [[ $TITLE_OVERRIDDEN == 1 ]]; }
# Echo asterisk if git state is dirty
gitDirty() { [[ $(git status 2> /dev/null | grep -o '\w\+' | tail -n1) != ("clean"|"") ]] && echo "*" }

# Show cwd when shell prompts for input.
precmd() {
   if overridden; then return; fi
   cwd=${$(pwd)##*/} # Extract current working dir only
   print -Pn "\e]0;$cwd$(gitDirty)\a" # Replace with $pwd to show full path
}

# Prepend command (w/o arguments) to cwd while waiting for command to complete.
preexec() {
   if overridden; then return; fi
   printf "\033]0;%s\a" "${1%% *} | $cwd$(gitDirty)" # Omit construct from $1 to show args
}
