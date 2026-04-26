# macOS specific configuration for Fish shell
# CLI tools come from Nix (Home Manager). Homebrew is for cask/font only;
# /opt/homebrew/bin is appended at PATH suffix so `brew` resolves without
# shadowing Nix-provided binaries.

if test -d /opt/homebrew
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    fish_add_path -aP /opt/homebrew/bin /opt/homebrew/sbin
    set -q MANPATH; or set MANPATH ''
    set -gx MANPATH /opt/homebrew/share/man $MANPATH
    set -q INFOPATH; or set INFOPATH ''
    set -gx INFOPATH /opt/homebrew/share/info $INFOPATH
end

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

# FZF configuration (programs.fzf.enable in Home Manager handles base init;
# these env vars layer on user-specific defaults).
if command -v fzf >/dev/null
    set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
    set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --border'
end

# Starship init is injected by Home Manager (programs.starship.enable).