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
brew upgrade pyright
brew upgrade lua-language-server
brew upgrade gopls
brew upgrade tailwindcss-language-server
brew upgrade bash-language-server
npm update -g vscode-langservers-extracted
npm update -g svelte-language-server
npm update -g graphql-language-service-cli
npm update -g emmet-ls
npm update -g @prisma/language-server

# Tools
brew upgrade black
brew upgrade stylua
brew upgrade shfmt
