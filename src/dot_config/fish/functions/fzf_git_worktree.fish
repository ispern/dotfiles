function fzf_git_worktree -d 'List and switch git worktrees using fzf.'
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        commandline -f repaint
        return 1
    end

    set -l query (commandline --current-buffer)
    if test -n $query
        set fzf_query --query "$query"
    end

    set -l base_command git worktree list
    set -l bind_commands "ctrl-d:execute(git worktree remove {1} 2>/dev/null || echo 'Failed to remove worktree')+reload($base_command)"
    set -l bind_str (string join ',' $bind_commands)

    set -l out ( \
    command $base_command | \
    fzf_wrapper $fzf_query \
        --prompt='Worktree > ' \
        --preview 'git -C {1} log --oneline -10 2>/dev/null || echo "Not a valid git directory"' \
        --bind $bind_str \
        --header='Enter: switch, C-d: delete'
  )
    if test -z $out
        commandline --function repaint
        return
    end

    # Extract worktree path (first field)
    set -l worktree_path (echo $out | awk '{ print $1 }')

    if test -d $worktree_path
        cd $worktree_path
        commandline -f repaint
    else
        echo "Error: Worktree path does not exist: $worktree_path"
        commandline -f repaint
        return 1
    end
end
