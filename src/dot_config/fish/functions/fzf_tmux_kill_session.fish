function fzf_tmux_kill_session

  set -l base_command tmux list-sessions

  set -l out ( \
    command $base_command | awk -F '[: ]' '{ print $1}' | \
    fzf_wrapper $fzf_query
  )
  if test -z $out
    commandline -f repaint
    return
  end

  set -l session_name (echo $out | awk '{ print $1 }')

  commandline "tmux kill-session -t $session_name"
  commandline -f execute
end