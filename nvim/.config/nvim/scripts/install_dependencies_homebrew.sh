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
brew install pyright  # Python
brew install lua-language-server  # Lua
brew install gopls  # Go
brew install tailwindcss-language-server
brew install bash-language-server
npm install -g vscode-langservers-extracted  # Html, Css...
npm install -g graphql-language-service-cli
npm install -g svelte-language-server
npm install -g emmet-ls
npm install -g @prisma/language-server

# Tools
brew install black
brew install stylua
brew install shfmt
