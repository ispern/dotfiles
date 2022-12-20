#!/usr/bin/env bash

# source and run dracula theme

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get-tmux-option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

main() {
  local theme
  theme="$(get-tmux-option "@dracula-theme" "pro")"

  if [ -f "$CURRENT_DIR/powerline/${theme}.tmuxtheme" ]; then
    tmux source-file "$CURRENT_DIR/powerline/${theme}.tmuxtheme"
    tmux source-file "$CURRENT_DIR/powerline/base.tmuxtheme"
  fi
}

main "$@"