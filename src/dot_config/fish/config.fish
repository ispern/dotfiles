source (dirname (status --current-filename))/config-base.fish

switch (uname)
  case Darwin
    source (dirname (status --current-filename))/config-osx.fish
  case Linux
    if string match -q "**microsoft**" (uname -r)
      source (dirname (status --current-filename))/config-linux-wsl.fish
    end

    source (dirname (status --current-filename))/config-linux.fish
  case '*'
    source (dirname (status --current-filename))/config-windows.fish
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
  source $LOCAL_CONFIG
end

