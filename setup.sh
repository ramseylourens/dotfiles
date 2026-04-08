#!/usr/bin/env zsh

echo "Changing the default shell to /bin/zsh" 
chsh -s /bin/zsh

# Check if running on osx and Icloud is enabled then copy dotfiles from icloud account
if [[ "$(uname)" == "Darwin" ]] && [[ -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles" ]]; then
    
    echo "Detected MACOSX and Icloud drive is active\nCopying dotfiles to home directory" 
    ln -sfn ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/

    if ! xcode-select -p &>/dev/null; then
        echo "Installing Xcode Command Line Interface Tools, Agree to the Agreement dialog"
        xcode-select --install
    fi

    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
# otherwise copy dotfiles from working directory
else
    echo "Copying dotfiles to home directory"  
    ln -sfn ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/
fi

echo "Symlinking .zshrc file to home directory" 
ln -sf ~/dotfiles/.zshrc ~/.zshrc

source ~/.zshrc

echo "dotfiles Setup Done" 
