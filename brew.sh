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
brew install grep
brew install wget
brew install tree

# Development
brew install oven-sh/bun/bun
brew install fnm  # Fast Node Manager

# Utilities
brew install z  # directory jumping
brew install the_silver_searcher  # ag

# Apps
brew install --cask ghostty

# Remove outdated versions from the cellar.
brew cleanup


echo "Done! Restart your shell or run: source ~/.zshrc"
