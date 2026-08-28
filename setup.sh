#!/usr/bin/env zsh
echo -e "\033[33mChanging the default shell to /bin/zsh\033[0m"
chsh -s /bin/zsh

if [[ "$(uname)" == "Linux" ]]; then
    echo -e "\033[33mDetected Linux VPS, setting up minimal dotfiles environment\033[0m"

    sudo apt-get update
    sudo apt-get install -y git curl zsh ca-certificates

    # If the repo is already cloned in the home folder
    [ -d "$HOME/dotfiles" ] || git clone https://github.com/ramseylourens/dotfiles.git "$HOME/dotfiles"

    ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
    ln -sf "$HOME/dotfiles/.zshenv" "$HOME/.zshenv"

    chsh -s /bin/zsh || true
    source "$HOME/.zshrc"
    exit 0
fi

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

        # Install these before brew bundle install because thats why
        brew install npm
        brew install --cask google-chrome
        brew install --cask iterm2
    fi

    if [ -f ~/dotfiles/config/Brewfile ]; then
        echo -e "\033[33mBrewfile exists downloading and installing your configuration\033[0m"
        brew bundle --verbose || true

        # Symlink Mongodb conf
        ln -sf ~/dotfiles/config/mongod.conf /usr/local/etc/mongod.conf

        # Symlink MySQL conf
        ln -sf ~/dotfiles/config/my.cnf ~/.my.cnf

        # Setup MySQL
        mysql_secure_installation

        # Setup Mkcert?
        mkcert -install


    fi

    if [ -f "$HOME/dotfiles/config/composer.json" ]; then
        cp "$HOME/dotfiles/config/composer.json" "$HOME/.composer/composer.json"
        composer global install
        valet install


        ln -sf ~/dotfiles/nginx /usr/local/etc/nginx
        ln -sf ~/dotfiles/valet ~/.config/valet
        
        valet secure swimtech && valet secure waterfiets && valet secure api.swimtech

        valet restart
    else
        echo "composer.json not found in ~/dotfiles/config"
    fi

    if [ -f "$HOME/dotfiles/config/npm-global.json" ]; then
        npm install -g $(node -e "const p = require('$HOME/dotfiles/config/npm-global.json'); console.log(Object.keys(p.dependencies).join(' '))")
    else
        echo "npm-global.json not found in ~/dotfiles/config"
    fi

    # Setup Google Chrome
    open -a "Google Chrome" && echo "Setup Google Chrome" && read -p "Press Enter to continue..."

    # Setup GitHub
    open -a "Google Chrome" "https://github.com" && read -p "Press Enter to continue..."

    # Setup Sites Repositories
    echo "Creating Sites folder inside the home directory"
    mkdir $HOME/Sites

    if [ ! -d ~/Sites/swimtech ]; then
        echo "Cloning SwimTechNL repository"
        git clone https://github.com/ramseylourens/swimtech ~/Sites/swimtech
        (
            cd ~/Code/grpc-swiftui
            npm install
            valet proxy swimtech.test http://localhost:3000
        )
    fi

    # Setup grpc-server repository
    if [ ! -d ~/Sites/grpc-server ]; then
        echo "Cloning grpc-server repository"
        git clone https://github.com/ramseylourens/grpc-server ~/Sites/grpc-server
        (
            cd ~/Sites/grpc-server
            composer install
            npm install
            npm run build
            cp .env.example .env
            php artisan key:generate
            php artisan config:clear
            php artisan cache:clear
            chmod -R 775 storage bootstrap/cache
            php artisan migrate:fresh --seed
        )
    fi

    # Setup website repository
    if [ ! -d ~/Sites/website ]; then
        echo "Cloning grpc-server repository"
        git clone https://github.com/ramseylourens/website ~/Sites/website
        (
            cd ~/Sites/website
            composer install
            npm install
            npm run build
            cp .env.example .env
            php artisan key:generate
            php artisan config:clear
            php artisan cache:clear
            chmod -R 775 storage bootstrap/cache
            php artisan migrate:fresh --seed
        )
    fi

    # Setup Code Repositories
    echo "Creating Code folder inside the home directory"
    mkdir $HOME/Code

    # Setup grpc-swiftui repository
    if [ ! -d ~/Code/grpc-swiftui ]; then
        echo "Cloning grpc-swiftui repository"
        git clone https://github.com/ramseylourens/grpc-swiftui ~/Code/grpc-swiftui
    fi

    # Setup SharedUIKIT repository
    if [ ! -d ~/Code/shareduikit ]; then
        echo "Cloning SharedUIKIT repository"
        git clone https://github.com/ramseylourens/shareduikit ~/Code/SharedUIKIT
    fi
else
    echo -e "\033[33mCopying dotfiles to home directory\033[0m"
    ln -sfn ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/
fi

echo -e "\033[33mSymlinking .zshrc and .zshenv file to home directory\033[0m"
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.zshenv ~/.zshenv

echo -e "\033[33mLoading dotfiles configuration into shell environment\033[0m"
source ~/.zshrc

echo -e "\033[33mdotfiles Setup Done\033[0m"
