function fzf_ghq_search_repository -d 'Search local repositories.'
  set -l base_command ghq list --full-path

  set -l out ( \
    command $base_command | \
    fzf_wrapper $fzf_query
  )
  if test -z $out
    commandline --function repaint
    return
  end

  cd $out
  commandline -f repaint
end