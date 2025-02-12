#!/usr/bin/env bash
brew update

brew upgrade ripgrep
brew upgrade fd
brew upgrade node
brew upgrade npm
brew upgrade fzf

# Code Runner
brew upgrade gcc

# Language servers
brew upgrade llvm
brew upgrade typescript-language-server
# brew upgrade pyright
brew install basedpyright
brew upgrade lua-language-server
brew upgrade gopls
brew upgrade bash-language-server
npm update -g vscode-langservers-extracted
npm update -g vim-language-server

# Debuggers
brew upgrade delve

# Tools
brew upgrade black
brew upgrade stylua
brew upgrade shfmt

# Rust Nightly (for blink.cmp)
brew upgrade rustup
rustup update nightly
