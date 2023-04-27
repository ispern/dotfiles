set -gx WIN_HOME /mnt/c/Users/h.matsuoka

# volta
# LinuxBrewでインストールされたnodeが優先されてしまうので、先にvoltaを読み込む
if test -d $HOME/.volta
  set -gx VOLTA_HOME $HOME/.volta
  set -gx PATH "$VOLTA_HOME/bin" $PATH
end

if test -d /home/linuxbrew/.linuxbrew/; or test -d $HOME/.linuxbrew
  if status --is-interactive
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  end

  # diff-highlight
  fish_add_path (brew --prefix)/Cellar/git/2.38.0/share/git-core/contrib/diff-highlight/

  # glib
  fish_add_path (brew --prefix glib)/bin
  fish_add_path (brew --prefix glib)/sbin
  set -gx LDFLAGS "-L$(brew --prefix glib)/lib"
  set -gx CPPFLAGS "-L$(brew --prefix glib)/include"
end

# Docker for Windows
fish_add_path /mnt/c/Program Files/Docker/Docker/resources/bin:/mnt/c/ProgramData/DockerDesktop/version-bin

# Windows Default Application
alias open "/mnt/c/Windows/explorer.exe"

# Google chorome
fish_add_path "/mnt/c/Program Files/Google/Chrome/Application"
set -gx BROWSER chrome.exe

# VSCode
fish_add_path "$WIN_HOME/AppData/Local/Programs/Microsoft VS Code/bin"

# NeoVim
set -gx NEOVIM_WIN_DIR "/mnt/c/Program Files/Neovim/bin/"
fish_add_path $NEOVIM_WIN_DIR

# rbenv
# export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
if type -q rbenv
  status --is-interactive; and source (rbenv init -|psub)
end
