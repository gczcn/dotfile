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
- and some language servers and formatters

### Installation
Run `stow nvim` to create an symlink for the neovim configuration

## Todoise
* **all**
  - [x] Use `stow` to manage configuration files
* neovim
  - [x] Rewrite the basic functions of the configuration file and change the current configuration file package name to `nvim_backup`
  > - [x] Start mode switching function ( and README change )
  > - [ ] Replace the text connection part in some plugins with the format string
  > - [ ] Make color scheme settings more convenient
  > - [x] Replace `telescope-z.nvim` with `telescope-zoxide`
  > - [ ] Find or make a better Tetris game
  > - [ ] Added menu for launching games
* wezterm
  - [ ] Configuration Modularity
