# macOS specific configuration for Fish shell

# Homebrew setup for Apple Silicon
if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    fish_add_path -gP /opt/homebrew/bin /opt/homebrew/sbin
    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

# GNU tools from Homebrew
if test -d /opt/homebrew/opt/coreutils/libexec/gnubin
    fish_add_path -gP /opt/homebrew/opt/coreutils/libexec/gnubin
end
if test -d /opt/homebrew/opt/gnu-sed/libexec/gnubin
    fish_add_path -gP /opt/homebrew/opt/gnu-sed/libexec/gnubin
end
if test -d /opt/homebrew/opt/findutils/libexec/gnubin
    fish_add_path -gP /opt/homebrew/opt/findutils/libexec/gnubin
end
if test -d /opt/homebrew/opt/grep/libexec/gnubin
    fish_add_path -gP /opt/homebrew/opt/grep/libexec/gnubin
end

# User binaries
if test -d "$HOME/.local/bin"
    fish_add_path -gP "$HOME/.local/bin"
end

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

# macOS specific aliases
alias ls "eza --icons"
alias ll "eza --icons -la"
alias la "eza --icons -a"
alias lt "eza --icons --tree"
alias cat "bat"
alias top "htop"

# Remove .DS_Store files recursively
alias rm_ds "find . -name '.DS_Store' -type f -delete"

# Quick Look from terminal
alias ql "qlmanage -p 2>/dev/null"

# Clipboard aliases
alias pbcopy "pbcopy"
alias pbpaste "pbpaste"

# 1Password SSH Agent setup (if available)
if test -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
end

# FZF configuration
if command -v fzf >/dev/null
    set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
    set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --border'
end

# Starship prompt
if command -v starship >/dev/null
    starship init fish | source
end