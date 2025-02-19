# dotfile
my dotfile

## Installation
```bash
git clone https://github.com/gczcn/dotfile.git
cd dotfile
```

## Neovim
### Dependencies
- [Neovim](https://neovim.io/) (latest stable version or nightly version)
- [ripgrep](https://github.com/BurntSushi/ripgrep/) for fzf.lua
- [fd](https://github.com/sharkdp/fd/) for fzf.lua
- make
- [nodejs](https://nodejs.org/)
- [npm](https://www.npmjs.com/)
- [fzf](junegunn/fzf) for fzf.lua
- and some language servers, formatters and debuggers

### Installation
Run `stow nvim` to create an symlink for the neovim configuration

## Todoise
* **all**
  - [x] Use `stow` to manage configuration files
* neovim
  - [ ] Archlinux installation dependency script fully automatic (I can't test it right now)
  - [ ] Fix the issue where the loaded language server could not be displayed on the status bar
  - [ ] Make non-treesitter folded columns display normally (I don't think I can do it)
* wezterm
  - [ ] Configuration Modularity
