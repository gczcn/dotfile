#!/usr/bin/env bash
brew update

brew install ripgrep
brew install fd
brew install node
brew install npm
brew install fzf

# Code Runner
brew install gcc

# Language servers
brew install llvm  # C and C++
brew install typescript-language-server  # Typescript
# brew install pyright  # Python
brew install basedpyright  # Python
brew install lua-language-server  # Lua
brew install gopls  # Go
brew install bash-language-server
npm install -g vscode-langservers-extracted  # Html, Css...
npm install -g vim-language-server

# Debuggers
brew install delve

# Tools
brew install black
brew install stylua
brew install shfmt

# Rust Nightly (for blink.cmp)
brew install rustup
rustup install nightly
