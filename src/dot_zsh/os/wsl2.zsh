export WIN_HOME=/mnt/c/Users/h.matsuoka
export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2)

# Docker for Windows
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin:/mnt/c/ProgramData/DockerDesktop/version-bin"

# Windows Default Application
# export PATH="$PATH:/mnt/c/Windows:/mnt/c/Windows/System32"
alias open="/mnt/c/Windows/explorer.exe"

# Google chorome
export PATH="$PATH:/mnt/c/Program Files/Google/Chrome/Application"
export BROWSER=chrome.exe

# VSCode
export PATH="$PATH:$WIN_HOME/AppData/Local/Programs/Microsoft VS Code/bin"
