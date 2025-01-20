#!/usr/bin/env bash
sudo pacman -Sy

yes | sudo pacman -S ripgrep
yes | sudo pacman -S fd
yes | sudo pacman -S nodejs
yes | sudo pacman -S npm
yes | sudo pacman -S fzf

# Code Runner
yes | sudo pacman -S gcc

# Language servers
yes | sudo pacman -S llvm
yes | sudo pacman -S clang
yes | sudo pacman -S typescript-language-server
yes | sudo pacman -S pyright
yes | sudo pacman -S lua-language-server
yes | sudo pacman -S gopls
yes | sudo pacman -S tailwindcss-language-server
yes | sudo pacman -S bash-language-server
yes | sudo pacman -S vscode-css-languageserver
yes | sudo pacman -S vscode-html-languageserver
yes | sudo pacman -S vscode-json-languageserver
yes | sudo pacman -S svelte-language-server
yes | sudo pacman -S graphql-client-cli
sudo npm update -g @prisma/language-server
sudo npm update -g emmet-ls
sudo npm update -g vim-language-server

# Tools
yes | sudo pacman -S python-black
yes | sudo pacman -S stylua
yes | sudo pacman -S shfmt

# Rust Nightly (for blink.cmp)
yes | sudo pacman -S rustup
rustup update nightly
