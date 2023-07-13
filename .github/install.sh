#!/usr/bin/env bash

# Script to set up my fish dotfiles
# 1. In home folder run:
# git clone https://github.com/chewblacka/fish.git ~/.config/fish
# 2. Then run this script:
# ~/.config/fish/.github/install.sh

echo "Script to install my fish files"
echo "First we source fisher and use it to install fish_plugins"
cd "$HOME/.config/fish/"
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update
echo "Done!"
