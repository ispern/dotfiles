function fzf_git_worktree_add -d 'Create a new git worktree using fzf.'
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        commandline -f repaint
        return 1
    end

    # Get repository root and name
    set -l repo_root (git rev-parse --show-toplevel)
    if test -z $repo_root
        echo "Error: Could not determine repository root"
        commandline -f repaint
        return 1
    end

    set -l repo_name (basename $repo_root)

    # Create ~/worktrees directory if it doesn't exist
    set -l worktrees_base ~/worktrees
    if not test -d $worktrees_base
        mkdir -p $worktrees_base
    end

    # Create repository directory if it doesn't exist
    set -l repo_dir $worktrees_base/$repo_name
    if not test -d $repo_dir
        mkdir -p $repo_dir
    end

    # Get branch list
    set -l base_command git branch -a --format='%(refname:short)'

    set -l branch_selected ( \
    command $base_command | \
    sed 's|^remotes/origin/||' | \
    sort -u | \
    fzf_wrapper $fzf_query \
        --prompt='Branch (or type new branch name) > ' \
        --preview 'git log --oneline -10 {1} 2>/dev/null || echo "New branch: {1}"' \
        --header='Enter: select existing or type new branch name'
  )

    if test -z $branch_selected
        commandline -f repaint
        return
    end

    # Check if branch exists
    set -l branch_name (echo $branch_selected | awk '{ print $1 }')
    set -l branch_exists (git branch -a --format='%(refname:short)' | sed 's|^remotes/origin/||' | grep -Fx "$branch_name")

    set -l worktree_path $repo_dir/$branch_name

    # Check if worktree path already exists
    if test -d $worktree_path
        echo "Error: Worktree already exists at: $worktree_path"
        commandline -f repaint
        return 1
    end

    # Create worktree
    if test -n "$branch_exists"
        # Existing branch
        echo "Creating worktree for existing branch: $branch_name"
        set -l create_command git worktree add $worktree_path $branch_name
    else
        # New branch
        echo "Creating worktree with new branch: $branch_name"
        set -l create_command git worktree add -b $branch_name $worktree_path
    end

    if command $create_command
        cd $worktree_path
        commandline -f repaint
    else
        echo "Error: Failed to create worktree"
        commandline -f repaint
        return 1
    end
end
