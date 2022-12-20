function fish_user_key_bindings
  fish_vi_key_bindings

  # fzf
  ## common
  bind -s --preset -M insert \cFf fzf_find_file
  bind -s --preset -M insert \cFd fzf_change_directory
  bind -s --preset -M insert \cR fzf_search_history

  ## gh and ghq
  bind -s --preset -M insert \cFi fzf_gh_issue
  bind -s --preset -M insert \cFr fzf_ghq_search_repository

  ## tmux
  bind -s --preset -M insert \cFt fzf_tmux_list
  bind -s --preset -M insert \cFk fzf_tmux_kill_session

  ## ssh
  bind -s --preset -M insert \cFs fzf_search_ssh_host
end
