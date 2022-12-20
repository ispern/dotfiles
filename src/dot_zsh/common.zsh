setopt complete_aliases

# alias
# ------------------------------

#alias vi="nvim"
export XDG_CONFIG_HOME=$HOME/.config

# global
alias ls="ls -v --color=auto"
alias ll='ls -ltraGvF'

# zsh
alias zshconfig="vi ~/.zshrc"
alias myzsh="vi $DOTFILES/.zsh/"

# tmux
alias tm='tmux'
alias tma='tmux attach'
alias tmd='tmux dettach'
alias tml='tmux list-window'

# git
alias g='git'

alias vi='vim'

# docker
alias d='docker'
alias dc='docker-compose'

# kubectl
# List and select pod name with fzf (https://github.com/junegunn/fzf)
# e.g.
#   kubectl exec -it P sh
#   kubectl delete pod P
alias k='kubectl'
alias fzfkubernetesalias="fzf --height 25 --header-lines=1 --reverse --multi --cycle"
alias -g P='$(kubectl get pods | fzfkubernetesalias | awk "{print \$1}")'

# Like P, global aliases about kubernetes resources
alias -g  PO='$(kubectl get pods | fzfkubernetesalias | awk "{print \$1}")'
alias -g  NS='$(kubectl get ns   | fzfkubernetesalias | awk "{print \$1}")'
alias -g  RS='$(kubectl get rs   | fzfkubernetesalias | awk "{print \$1}")'
alias -g SVC='$(kubectl get svc  | fzfkubernetesalias | awk "{print \$1}")'
alias -g ING='$(kubectl get ing  | fzfkubernetesalias | awk "{print \$1}")'

# References
# - https://github.com/c-bata/kube-prompt
# - https://github.com/cloudnativelabs/kube-shell

# zsh setting
# -------------------------------------

bindkey -v

# vi
bindkey -M vicmd 'V'  vi-vlines-mode
bindkey -M vicmd 'v'  vi-visual-mode
bindkey -M vivis ' '  vi-visual-forward-char
bindkey -M vivis ','  vi-visual-rev-repeat-find
bindkey -M vivis '0'  vi-visual-bol
bindkey -M vivis ';'  vi-visual-repeat-find
bindkey -M vivis 'B'  vi-visual-backward-blank-word
bindkey -M vivis 'C'  vi-visual-substitute-lines
bindkey -M vivis 'D'  vi-visual-kill-and-vicmd
bindkey -M vivis 'E'  vi-visual-forward-blank-word-end
bindkey -M vivis 'F'  vi-visual-find-prev-char
bindkey -M vivis 'G'  vi-visual-goto-line
bindkey -M vivis 'I'  vi-visual-insert-bol
bindkey -M vivis 'J'  vi-visual-join
bindkey -M vivis 'O'  vi-visual-exchange-points
bindkey -M vivis 'R'  vi-visual-substitute-lines
bindkey -M vivis 'S ' vi-visual-surround-space
bindkey -M vivis "S'" vi-visual-surround-squote
bindkey -M vivis 'S"' vi-visual-surround-dquote
bindkey -M vivis 'S(' vi-visual-surround-parenthesis
bindkey -M vivis 'S)' vi-visual-surround-parenthesis
bindkey -M vivis 'T'  vi-visual-find-prev-char-skip
bindkey -M vivis 'U'  vi-visual-uppercase-region
bindkey -M vivis 'V'  vi-visual-exit-to-vlines
bindkey -M vivis 'W'  vi-visual-forward-blank-word
bindkey -M vivis 'Y'  vi-visual-yank
bindkey -M vivis '^M' vi-visual-yank
bindkey -M vivis '^[' vi-visual-exit
bindkey -M vivis 'b'  vi-visual-backward-word
bindkey -M vivis 'c'  vi-visual-change
bindkey -M vivis 'd'  vi-visual-kill-and-vicmd
bindkey -M vivis 'e'  vi-visual-forward-word-end
bindkey -M vivis 'f'  vi-visual-find-next-char
bindkey -M vivis 'gg' vi-visual-goto-first-line
bindkey -M vivis 'h'  vi-visual-backward-char
bindkey -M vivis 'j'  vi-visual-down-line
bindkey -M vivis 'jj' vi-visual-exit
bindkey -M vivis 'k'  vi-visual-up-line
bindkey -M vivis 'l'  vi-visual-forward-char
bindkey -M vivis 'o'  vi-visual-exchange-points
bindkey -M vivis 'p'  vi-visual-put
bindkey -M vivis 'r'  vi-visual-replace-region
bindkey -M vivis 't'  vi-visual-find-next-char-skip
bindkey -M vivis 'u'  vi-visual-lowercase-region
bindkey -M vivis 'v'  vi-visual-eol
bindkey -M vivis 'w'  vi-visual-forward-word
bindkey -M vivis 'y'  vi-visual-yank

# anyframe
bindkey '^ic' anyframe-widget-cdr
bindkey '^ih' anyframe-widget-execute-history
bindkey '^ip' anyframe-widget-put-history
bindkey '^ig' anyframe-widget-cd-ghq-repository
bindkey '^ik' anyframe-widget-kill
bindkey '^ib' anyframe-widget-insert-git-branch
bindkey '^bs' anyframe-widget-tmux-attach

# Important
zstyle ':completion:*:default' menu select=2

# Completing Groping
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'
zstyle ':completion:*' group-name ''

# Completing misc
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
zstyle ':completion:*' use-cache true
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directory
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' list-colors ${LS_COLORS}

# default: --
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true

# Menu select
zmodload -i zsh/complist
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^l' vi-forward-char

autoload -Uz cdr
autoload -Uz history-search-end
autoload -Uz modify-current-argument
autoload -Uz smart-insert-last-word
autoload -Uz terminfo
autoload -Uz vcs_info
autoload -Uz zcalc
autoload -Uz zmv
autoload -Uz run-help-git
autoload -Uz run-help-svk
autoload -Uz run-help-svn

# zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

setopt auto_cd
setopt auto_pushd

# Do not print the directory stack after pushd or popd.
#setopt pushd_silent
# Replace 'cd -' with 'cd +'
setopt pushd_minus

# Ignore duplicates to add to pushd
setopt pushd_ignore_dups

# pushd no arg == pushd $HOME
setopt pushd_to_home

# Check spell command
setopt correct

# Check spell all
setopt correct_all

# Prohibit overwrite by redirection(> & >>) (Use >! and >>! to bypass.)
setopt no_clobber

# Deploy {a-c} -> a b c
setopt brace_ccl

# Enable 8bit
setopt print_eight_bit

# sh_word_split
setopt sh_word_split

# Change
#~$ echo 'hoge' \' 'fuga'
# to
#~$ echo 'hoge '' fuga'
setopt rc_quotes

# Case of multi redirection and pipe,
# use 'tee' and 'cat', if needed
# ~$ < file1  # cat
# ~$ < file1 < file2        # cat 2 files
# ~$ < file1 > file3        # copy file1 to file3
# ~$ < file1 > file3 | cat  # copy and put to stdout
# ~$ cat file1 > file3 > /dev/stdin  # tee
setopt multios

# Automatically delete slash complemented by supplemented by inserting a space.
setopt auto_remove_slash

# No Beep
setopt no_beep
setopt no_list_beep
setopt no_hist_beep

# Expand '=command' as path of command
# e.g.) '=ls' -> '/bin/ls'
setopt equals

# Do not use Ctrl-s/Ctrl-q as flow control
setopt no_flow_control

# Look for a sub-directory in $PATH when the slash is included in the command
setopt path_dirs

# Show exit status if it's except zero.
setopt print_exit_value

# Show expaning and executing in what way
#setopt xtrace

# Confirm when executing 'rm *'
setopt rm_star_wait

# Let me know immediately when terminating job
setopt notify

# Show process ID
setopt long_list_jobs

# Resume when executing the same name command as suspended process name
setopt auto_resume

# Disable Ctrl-d (Use 'exit', 'logout')
#setopt ignore_eof

# Ignore case when glob
setopt no_case_glob

# Use '*, ~, ^' as regular expression
# Match without pattern
#  ex. > rm *~398
#  remove * without a file "398". For test, use "echo *~398"
setopt extended_glob

# If the path is directory, add '/' to path tail when generating path by glob
setopt mark_dirs

# Automaticall escape URL when copy and paste
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Prevent overwrite prompt from output withour cr
setopt no_prompt_cr

# Let me know mail arrival
setopt mail_warning

# Do not record an event that was just recorded again.
setopt hist_ignore_dups

# Delete an old recorded event if a new event is a duplicate.
setopt hist_ignore_all_dups
setopt hist_save_nodups

# Expire a duplicate event first when trimming history.
setopt hist_expire_dups_first

# Do not display a previously found event.
setopt hist_find_no_dups

# Shere history
setopt share_history

# Pack extra blank
setopt hist_reduce_blanks

# Write to the history file immediately, not when the shell exits.
setopt inc_append_history

# Remove comannd of 'hostory' or 'fc -l' from history list
setopt hist_no_store

# Remove functions from history list
setopt hist_no_functions

# Record start and end time to history file
setopt extended_history

# Ignore the beginning space command to history file
setopt hist_ignore_space

# Append to history file
setopt append_history

# Edit history file during call history before executing
setopt hist_verify

# Enable history system like a Bash
setopt bang_hist

if :; then
    setopt auto_param_slash
    setopt list_types
    setopt auto_menu
    setopt auto_param_keys
    setopt interactive_comments
    setopt magic_equal_subst
    setopt complete_in_word
    setopt always_last_prompt
    setopt globdots
fi

# fzf color
# https://minsw.github.io/fzf-color-picker/
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=fg:#f8f8f2,bg:#2a212c,hl:#9f70a9 --color=fg+:#f8f8f2,bg+:#544158,hl+:#c783d4 --color=info:#9f70a9,prompt:#9f70a9,pointer:#af5fff --color=marker:#9f70a9,spinner:#9f70a9,header:#9f70a9'

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

_fix_cursor() {
   echo -ne '\e[5 q'
}
precmd_functions+=(_fix_cursor)


