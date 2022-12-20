function fzf_wrapper --description "Prepares some environment variables before executing fzf."
    set --local --export SHELL (command --search fish)

    # https://github.com/junegunn/fzf#environment-variables
    if not set --query FZF_DEFAULT_OPTS
      set -gx FZF_DEFAULT_OPTS '--cycle --ansi --layout=reverse --border --height=50% --preview-window=wrap --marker="*"'
    end

    if not set --query TMUX
      fzf $argv
    else
      # FZF_TMUX_OTPS is not working?
      fzf-tmux -p 80% $argv
    end
end
