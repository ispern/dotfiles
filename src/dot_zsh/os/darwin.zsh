# macOS specific configuration for Zsh

# Environment variables
export TERM="xterm-256color"
export SHELL=/opt/homebrew/bin/fish
export XDG_CONFIG_HOME=$HOME/.config
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# Homebrew setup for Apple Silicon
if [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# GNU tools from Homebrew
if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
fi
if [ -d "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi
if [ -d "/opt/homebrew/opt/findutils/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
fi
if [ -d "/opt/homebrew/opt/grep/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
fi

# User binaries
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# FZF configuration
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
fi

# 1Password SSH Agent setup (if available)
if [ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# rbenv setup (if installed)
if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init - zsh)"
fi

# nodenv setup (if installed)
if [ -d "$HOME/.nodenv" ]; then
    export PATH="$HOME/.nodenv/bin:$PATH"
    eval "$(nodenv init -)"
fi

# pyenv setup (if installed)
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# Aliases
alias ls='eza --icons'
alias ll='eza --icons -la'
alias la='eza --icons -a'
alias lt='eza --icons --tree'
alias cat='bat'
alias top='htop'
alias grep='grep --color=auto'

# macOS specific aliases
alias rm_ds="find . -name '.DS_Store' -type f -delete"
alias ql="qlmanage -p 2>/dev/null"

# Clipboard aliases
alias pbcopy='pbcopy'
alias pbpaste='pbpaste'

# anyframe settings for fzf integration
if command -v fzf-tmux &> /dev/null; then
    zstyle ":anyframe:selector:" use fzf-tmux
fi