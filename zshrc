# Weihao's zsh config
# https://github.com/swyzzwh/dotfiles

# Path to oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme - random for variety
ZSH_THEME="random"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# --- Environment ---
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8 2>/dev/null || true)"
export GOPATH="$HOME/go"
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"

# Postgres.app (if installed)
[ -d "/Applications/Postgres.app" ] && export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# MySQL client (homebrew)
[ -d "/opt/homebrew/opt/mysql-client/bin" ] && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# --- NVM ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Conda (auto-configured by conda init) ---
# Run `conda init zsh` after installing miniconda

# --- Aliases ---
alias c="claude --dangerously-skip-permissions"
alias claude='npx -y @anthropic-ai/claude-code@latest'

# SSH aliases - customize these for your machines
# alias ssh-myserver="ssh user@hostname"

# Docker login - run manually with your token:
# echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
