#!/usr/bin/env zsh
echo -e "\033[33mChanging the default shell to /bin/zsh\033[0m"
chsh -s /bin/zsh

# Check if running on osx and Icloud is enabled then copy dotfiles from icloud account
if [[ "$(uname)" == "Darwin" ]] && [[ -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles" ]]; then
    
    echo -e "\033[33mDetected MACOSX and Icloud drive is active\nCopying dotfiles to home directory\033[0m" 
    ln -sfn ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/

    if ! xcode-select -p &>/dev/null; then
        echo -e "\033[33mInstalling Xcode Command Line Interface Tools, Agree to the Agreement dialog\033[0m"
        xcode-select --install
    fi

    if ! command -v brew &>/dev/null; then
        echo -e "\033[33mInstalling Homebrew\033[0m"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [ -f Brewfile ]; then
        echo -e "\033[33mBrewfile exists downloading and installing your configuration\033[0m"
        brew bundle --verbose || true

    fi
    
else
    echo -e "\033[33mCopying dotfiles to home directory\033[0m"
    ln -sfn ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/
fi

echo -e "\033[33mSymlinking .zshrc file to home directory\033[0m"
ln -sf ~/dotfiles/.zshrc ~/.zshrc

if [ ! -f ~/.env ]; then
    echo -e "\033[33m\033[33mCreating .env file for Environment secrets\033[0m"
    cp .env.example ~/.env
fi

echo -e "\033[33mLoading dotfiles configuration into shell environment\033[0m"
source ~/.zshrc

echo -e "\033[33mdotfiles Setup Done\033[0m"
