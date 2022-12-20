function fzf_find_file
  set -l query (commandline --current-buffer)
  if test -n $query
    set fzf_query --query "$query"
  end

  set -l base_command fd --type f
  set -l preview_command bat --color=always --style=numbers --line-range=:500

  set -l out ( \
    command $base_command | \
    fzf_wrapper $fzf_query \
        --preview "$preview_command {}"
  )
  if test -z $out
    commandline --function repaint
    return
  end

  commandline "vim $out"
  commandline -f execute
end