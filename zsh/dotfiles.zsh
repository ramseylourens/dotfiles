function dotfiles() {
    if [[ "$1" == "sync" ]]; then
        echo "sync mode"
        # parse the json and reinstall
        (
            cd ~/dotfiles/config

            echo "Backing up Homebrew"
            brew bundle dump --force
        
            echo "Backing up npm"
            npm list -g --depth=0 --json > ./npm-global.json

            echo "Backing up composer"
            if [[ -f ~/.composer/composer.json && ! -L ~/.composer/composer.json && ~/.composer/composer.json -ot ~/dotfiles/config/composer.json ]]; then
                cp ~/.composer/composer.json ./composer.json
                rm ~/.composer/composer.json
                ln -s ~/dotfiles/config/composer.json ~/.composer/composer.json
            fi       
    
        )
    elif [[ "$1" == "install" ]]; then
        echo "Installing global packages"
        (
            cd ~/dotfiles
    
            echo "Installing npm global packages"
            cat ./config/npm-global.json | jq -r '.dependencies | keys[]' | xargs npm install -g

            echo "Installing composer global packages"
            composer global install

        )
    elif [[ "$1" == "upgrade" ]]; then
        echo "Upgrading global packages"
        (
    
            echo "Upgrading homebrew packages"
            brew upgrade

            echo "Upgrading composer global packages"
            composer global upgrade

            echo "Upgrading npm global packages"
            npm update -g

        )  
    elif [[ "$1" == "code" ]]; then
        echo "Opening in dotfiles in VsCode"
        (
            cd "$ZSH"
            code .
        )
    elif [[ "$1" == "reload" ]]; then
        echo "Reloading Terminal Environment"
        source "$HOME/.zshrc"
    else
        echo "List of commands"
    fi
}


