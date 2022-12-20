function fzf_change_directory
  set -l query (commandline --current-buffer)
  if test -n $query
    set fzf_query --query "$query"
  end

  set -l base_command fd --type d
  set -l preview_command exa --tree --level=2

  set -l out ( \
    command $base_command | \
    fzf_wrapper $fzf_query \
        --preview "$preview_command {}"
  )
  if test -z $out
    commandline --function repaint
    return
  end

  commandline "cd $out"
  commandline -f execute
end