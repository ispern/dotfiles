# macOS specific configuration for Zsh
# CLI tools are provided by Nix (Home Manager). Homebrew remains for cask/font.
# PATH order: ~/bin -> ~/.local/bin -> Nix -> system -> Homebrew suffix.

# Environment variables
export TERM="xterm-256color"
export SHELL=/opt/homebrew/bin/fish
export XDG_CONFIG_HOME=$HOME/.config
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# Homebrew (cask/font only). Append /opt/homebrew/{bin,sbin} so `brew` is found
# without shadowing Nix-provided CLI tools.
if [ -d "/opt/homebrew/bin" ]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    case ":$PATH:" in
        *:/opt/homebrew/bin:*) ;;
        *) export PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin" ;;
    esac
fi

# User binaries (highest priority)
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# FZF user defaults (programs.fzf.enable provides base init via Home Manager)
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
fi

# 1Password SSH Agent setup (if available)
if [ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# Starship prompt (also provided via programs.starship for fish; zsh init here)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
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
