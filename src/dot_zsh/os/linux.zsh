USER=`whoami`

# Global
export ZPLUG_HOME=$HOME/.zplug
export TERM="xterm-256color"
export COLORTERM=truecolor
export SHELL=/usr/bin/zsh

export PATH="$PATH:$HOME/.local/bin:$HOME/.dotfiles/bin"

# Linuxbrew
if [ -d /home/linuxbrew/.linuxbrew/ ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  source $(brew --prefix)/share/zsh/site-functions
fi

# rbenv
eval "$(rbenv init - zsh)"
export GEM_HOME=$HOME/.rbenv/versions/3.0.2/lib/ruby/gems/3.0.0

# Starship
eval "$(starship init zsh)"

# anyframe
zstyle ":anyframe:selector:" use fzf-tmux

# volta
if [ -d "$HOME/.volta" ]; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/bin/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/bin/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/bin/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/bin/google-cloud-sdk/completion.zsh.inc"; fi
