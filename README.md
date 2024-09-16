# configuration for dev system

symlinks for dotfiles
```
ln -s $HOME/.config/dotfiles/nvim $HOME/.config/nvim
ln -s $HOME/.config/dotfiles/tmux $HOME/.config/tmux
ln -s $HOME/.config/dotfiles/kitty $HOME/.config/kitty

... any other config that has to be symlinked
```

installs
- brew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- nvm: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"`
- rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"`

- cp .zshrc: `cp $HOME/.config/dotfiles/.zshrc $HOME/.zshrc`

commands
```
nvm install --lts --default
brew install ripgrep
brew install neovim
brew install fzf
brew install tmux
brew install python
```
