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
    else
        echo "List of commands"
    fi
}


