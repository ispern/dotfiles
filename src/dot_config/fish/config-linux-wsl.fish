set -gx WIN_HOME /mnt/c/Users/h.matsuoka

# Docker for Windows
set -gx PATH /mnt/c/Program Files/Docker/Docker/resources/bin:/mnt/c/ProgramData/DockerDesktop/version-bin $PATH

# Windows Default Application
alias open "/mnt/c/Windows/explorer.exe"

# Google chorome
set -gx PATH "/mnt/c/Program Files/Google/Chrome/Application" $PATH
set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /lib/x86_64-linux-gnu
set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu
set -gx BROWSER chrome.exe

# VSCode
set -gx PATH "$WIN_HOME/AppData/Local/Programs/Microsoft VS Code/bin" $PATH

# NeoVim
set -gx NEOVIM_WIN_DIR "/mnt/c/Program Files/Neovim/bin/"
set -gx PATH $NEOVIM_WIN_DIR $PATH

# Linuxbrew
if test -d /home/linuxbrew/.linuxbrew/
  eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

  # diff-highlight
  set -gx PATH /home/linuxbrew/.linuxbrew/Cellar/git/2.38.0/share/git-core/contrib/diff-highlight/ $PATH
end

# Starship
if type -q starship
  starship init fish | source
end

# rbenv
# export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
if type -q rbenv
  status --is-interactive; and source (rbenv init -|psub)
end

# volta
if test -d $HOME/.volta
  set -gx VOLTA_HOME $HOME/.volta
  set -gx PATH $VOLTA_HOME/bin $PATH
end
