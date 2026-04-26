set -gx WIN_HOME /mnt/c/Users/h.matsuoka
set ssh_exe_path (which ssh.exe 2>/dev/null)

# Configure ssh forwarding (Windows 側 1Password ssh-agent を WSL に橋渡し)
# https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows
set -gx SSH_AUTH_SOCK $HOME/.ssh/agent.sock

if ! ss -a | grep -q $SSH_AUTH_SOCK >/dev/null 2>&1
    if test -S $SSH_AUTH_SOCK
        echo "removing previous socket..."
        rm -f $SSH_AUTH_SOCK
    end
    echo "Starting SSH-Agent relay..."
    set -x NPIPERELAY $HOME/bin/npiperelay.exe
    eval (socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"$NPIPERELAY -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
end

if test -n "$ssh_exe_path"
    alias ssh="$ssh_exe_path"
    alias ssh-add=(string replace ssh.exe ssh-add.exe $ssh_exe_path)
end

# pnpm (per-user; 必要なマシンだけ有効化)
if test -d $HOME/.local/share/pnpm
    set -gx PNPM_HOME $HOME/.local/share/pnpm
    set -gx PATH "$PNPM_HOME/bin" $PATH
end

# Docker for Windows (Docker Desktop for Windows 利用時のみ意味あり)
fish_add_path /mnt/c/Program Files/Docker/Docker/resources/bin:/mnt/c/ProgramData/DockerDesktop/version-bin

# Windows Default Application
alias open "/mnt/c/Windows/explorer.exe"

# Google Chrome
fish_add_path "/mnt/c/Program Files/Google/Chrome/Application"
set -gx BROWSER chrome.exe

# VSCode (Windows 側にインストールされている前提)
fish_add_path "$WIN_HOME/AppData/Local/Programs/Microsoft VS Code/bin"

# Neovim (Windows 側 Neovim を使う場合)
set -gx NEOVIM_WIN_DIR "/mnt/c/Program Files/Neovim/bin/"
fish_add_path $NEOVIM_WIN_DIR
