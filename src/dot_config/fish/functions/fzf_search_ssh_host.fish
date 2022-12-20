function fzf_search_ssh_host --description "Search ssh_config host."
  set -l query (commandline --current-buffer)
  if test -n $query
    set fzf_query --query "$query"
  end

  set -l base_command rg -e '^Host' --no-heading --no-line-number ~/.ssh/

  set -l out ( \
    command $base_command | awk -F "[: ]" '{print $3}' | \
    fzf_wrapper $fzf_query
  )

  if test -z $out
    commandline --function repaint
    return
  end

  commandline "ssh $out"
  commandline -f execute
end