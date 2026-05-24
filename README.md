# dotfiles
 
Cross-platform configuration managed by [chezmoi](https://www.chezmoi.io/). Targets macOS and [Bazzite](https://bazzite.gg/) (Fedora Atomic).
 
Managed:
 
- `zsh` (`~/.zshrc`, machine-local overrides via `~/.zshrc.local`)
- `tmux` (config, sessionizer, cheat-sheet scripts)
- Neovim
- Ghostty
- SQLFluff
- Firefox hardening ([Betterfox](https://github.com/yokoffing/Betterfox) + personal overrides, `userChrome.css`, `userContent.css`, `containers.json`, `xulstore.json`)

## Prerequisites
 
- [chezmoi](https://www.chezmoi.io/install/)
- Git, with SSH access to GitHub
- [Homebrew](https://brew.sh/) (macOS and Linux)
- Zsh (Bazzite: `rpm-ostree install zsh && systemctl reboot`)
Runtime tools used by configs:
 
```sh
brew install neovim tmux fzf ripgrep
```
 
Ghostty: install separately ([ghostty.org](https://ghostty.org/)).

## Bootstrap a new machine
 
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init mjanssen
chezmoi diff
chezmoi apply -v
```
 
`~/.local/bin` must be on `PATH`.
 
After first apply, switch the chezmoi source remote to SSH so future pushes work without prompts:
 
```sh
chezmoi cd
git remote set-url origin git@github.com:mjanssen/dotfiles.git
exit
```
  
chezmoi prefixes used:
 
| Prefix          | Meaning                                                          |
|-----------------|------------------------------------------------------------------|
| `dot_`          | Target filename starts with `.`                                  |
| `executable_`   | Apply mode `0755`                                                |
| `run_onchange_` | Script under `.chezmoiscripts/`; re-runs when its content changes |
 
Reference: [chezmoi target types](https://www.chezmoi.io/reference/target-types/).

## Machine-local overrides
 
`~/.zshrc` ends with:
 
```sh
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```
 
Per-machine aliases, exports, and host-specific tweaks go in `~/.zshrc.local`. Not managed by chezmoi, not tracked in git.
 
```sh
touch ~/.zshrc.local
chmod 600 ~/.zshrc.local
```
