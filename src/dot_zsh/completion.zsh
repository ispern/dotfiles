# Git
# -------------------------------------
_fzf_complete_git() {
    ARGS="$@"
    local branches
    branches=$(git branch -vv --all)
    if [[ $ARGS == 'git co'* ]]; then
        _fzf_complete --reverse --multi -- "$@" < <(
            echo $branches
        )
    else
        eval "zle ${fzf_default_completion:-expand-or-complete}"
    fi
}

_fzf_complete_git_post() {
    awk '{print $1}'
}

# ssh
# -------------------------------------
unset -f _fzf_complete_ssh > /dev/null 2>&1
_fzf_complete_ssh() {
  _fzf_complete '+m' "ssh $@" < <(
    cat <(cat ~/.ssh/config ~/.ssh/conf.d/**/config /etc/ssh/ssh_config 2> /dev/null | command grep -i '^host ' | command grep -v '[*?]' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}')         <(command grep -oE '^[[a-z0-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }')         <(command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0') |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
#   _fzf_complete --reverse --multi -- "$@" < <(
#     setopt localoptions nonomatch
#     command cat <(cat ~/.ssh/config ~/.ssh/conf.d/**/config 2> /dev/null | command grep -i '^\s*host\? ' | awk '{for (i = 2; i <= NF; i++) print $1 " " $i}' | command grep -v '[*?]') \
#         <(command grep -oE '^[[a-z1-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | tr -d '[' | awk '{ print $1 " " $1 }') |
#         awk '{if (length($2) > 0) {print $2}}' | sort -u
#   )
}
zle -N _fzf_complete_ssh
bindkey '^is' _fzf_complete_ssh