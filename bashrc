# ~/.bashrc — Git Bash on Windows

# --- History ---
# Flush to disk after every command so history survives hard kills (reboot,
# wezterm crash, etc.). Default Git Bash has HISTSIZE unset, which is why
# up-arrow was empty after reboot.
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT='%F %T '
shopt -s histappend
# Append + re-read on every prompt so new sessions see other sessions' history
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND:-}"

# --- Aliases ---
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
