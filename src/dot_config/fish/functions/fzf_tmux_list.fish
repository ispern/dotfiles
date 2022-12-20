function fzf_tmux_list

  set -l base_command tmux list-sessions

  set -l out ( \
    command $base_command | awk -F '[: ]' '{ print $1}' | \
    fzf_wrapper $fzf_query
  )
  if test -z $out
    commandline -f repaint
    return
  end

  [ -n "$TMUX" ] && set -l change_command switch-client || set -l change_command attach-session;

  set -l session_name (echo $out | awk '{ print $1 }')

  commandline "tmux $change_command -t $session_name"
  commandline -f execute
end