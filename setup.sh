#!/usr/bin/env zsh

echo "Changing the default shell to /bin/zsh" 
chsh -s /bin/zsh

# Check if running on osx and Icloud is enabled then copy dotfiles from icloud account
if [[ "$OS" == "macOS" ]] && [[ -d "$HOME/Library/Mobile Documents" ]]; then
    echo "Detected MACOSX and Icloud drive is active\nCopying dotfiles to home directory" 
    ln -sf ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/.dotfiles

    echo "Installing Xcode Command Line Interface Tools, Agree to the Agreement dialog"
    xcode-select --install 

    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# otherwise copy dotfiles from working directory
else
    echo "Copying dotfiles to home directory"  
    ln -sfn "$PWD" "$HOME/.dotfiles"
fi

echo "Symlinking .zshrc file to home directory" 
ln -sf ~/.dotfiles/.zshrc ~/.zshrc

source ~/.zshrc

echo "dotfiles Setup Done" 
