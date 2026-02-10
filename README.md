# Weihao's Dotfiles

Personal shell and terminal configuration for macOS.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/swyzzwh/dotfiles/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/swyzzwh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## What's Included

- **zshrc** - Zsh config with oh-my-zsh, NVM, Go, useful aliases
- **wezterm.lua** - WezTerm terminal config with Tokyo Night theme, transparency, keybindings

## Dependencies

The install script will prompt you to install these:

- [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) - Coding font with icons
- [NVM](https://github.com/nvm-sh/nvm) - Node version manager
- (Optional) [Miniconda](https://docs.conda.io/en/latest/miniconda.html) - Python environment manager

## Customization

After installation, you may want to:

1. Add SSH aliases in `~/.zshrc`
2. Set up Docker login: `echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin`
3. Run `conda init zsh` if using Conda

## License

MIT
