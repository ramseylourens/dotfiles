#!/usr/bin/env bash

# Check if running on osx and Icloud is enabled then copy dotfiles from icloud account
if [[ "$OS" == "macOS" ]] && [[ -d "$HOME/Library/Mobile Documents" ]]; then
    echo "Detected MACOSX and Icloud drive is active\nCopying dotfiles to home directory" 
    ln -sf ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/.dotfiles
# otherwise copy dotfiles from working directory
else
    echo "Copying dotfiles to home directory"  
    ln -sfn "$PWD" "$HOME/.dotfiles"
fi

echo "Symlinking .zshrc file to home directory" 
ln -sf ~/.dotfiles/.zshrc ~/.zshrc

source ~/.zshrc

echo "dotfiles Setup Done" 
