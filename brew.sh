#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we're using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Core tools
brew install git
brew install gh
brew install jq
brew install wget
brew install tree

# Development
brew install oven-sh/bun/bun
brew install fnm  # Fast Node Manager
brew install rbenv ruby-build

# Utilities
brew install z  # directory jumping
brew install the_silver_searcher  # ag

# Apps
brew install --cask ghostty

# Pure prompt for zsh
mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure" 2>/dev/null || echo "Pure already installed"

# Remove outdated versions from the cellar.
brew cleanup

echo "Done! Restart your shell or run: source ~/.zshrc"
