# Global
#set -gx TERM "xterm-256color"
#set -gx COLORTERM "truecolor"
if test -d "$HOME/.local/bin"
  set -gx PATH "$HOME/bin" $PATH
end

if test -d "$HOME/.local/bin"
  set -gx PATH "$HOME/.local/bin" $PATH
end