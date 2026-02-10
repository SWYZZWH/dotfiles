#!/bin/bash
# Weihao's dotfiles installer
# Usage: curl -fsSL https://raw.githubusercontent.com/swyzzwh/dotfiles/main/install.sh | bash

set -e

REPO="https://github.com/swyzzwh/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "🚀 Installing Weihao's dotfiles..."

# Clone repo
if [ -d "$DOTFILES_DIR" ]; then
    echo "📦 Updating existing dotfiles..."
    cd "$DOTFILES_DIR" && git pull
else
    echo "📦 Cloning dotfiles..."
    git clone "$REPO" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# Backup existing configs
backup_if_exists() {
    if [ -f "$1" ] && [ ! -L "$1" ]; then
        echo "📋 Backing up $1 to $1.backup"
        mv "$1" "$1.backup"
    fi
}

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🔧 Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Link zshrc
backup_if_exists "$HOME/.zshrc"
echo "🔗 Linking .zshrc"
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

# Link wezterm config
backup_if_exists "$HOME/.wezterm.lua"
echo "🔗 Linking .wezterm.lua"
ln -sf "$DOTFILES_DIR/wezterm.lua" "$HOME/.wezterm.lua"

# Install dependencies reminder
echo ""
echo "✅ Dotfiles installed!"
echo ""
echo "📝 Post-install steps:"
echo "   1. Install WezTerm: brew install --cask wezterm"
echo "   2. Install JetBrainsMono Nerd Font: brew install --cask font-jetbrains-mono-nerd-font"
echo "   3. Install NVM: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
echo "   4. (Optional) Install Miniconda and run: conda init zsh"
echo ""
echo "🎉 Restart your terminal to apply changes!"
