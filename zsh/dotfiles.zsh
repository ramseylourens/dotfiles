# The package manager (DOTFILES_PM) is detected per machine in helpers/platform.zsh

# Writes the requested MacPorts ports, with variants, to macports.txt
function _dotfiles_port_dump() {
    /opt/local/bin/port -q installed requested | awk '/\(active\)/ {
        out = $1
        n = split($2, v, "+")
        for (i = 2; i <= n; i++) if (v[i] != "universal") out = out " +" v[i]
        print out
    }' > ./macports.txt
}

function _dotfiles_port_install() {
    local line
    while IFS= read -r line; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        sudo /opt/local/bin/port install ${=line} || echo "Failed to install: $line"
    done < ~/dotfiles/config/macports.txt
}

function dotfiles() {
    local pm="$DOTFILES_PM"

    if [[ "$1" == "sync" ]]; then
        echo "sync mode ($pm)"
        # parse the json and reinstall
        (
            cd ~/dotfiles/config

            case "$pm" in
                brew)
                    echo "Backing up Homebrew"
                    brew bundle dump --force
                    ;;
                port)
                    echo "Backing up MacPorts"
                    _dotfiles_port_dump
                    code --list-extensions > ./vscode-extensions.txt
                    ;;
                *)
                    echo "No supported package manager found, skipping system packages"
                    ;;
            esac
        
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
        echo "Installing global packages ($pm)"
        (
            cd ~/dotfiles

            case "$pm" in
                brew)
                    echo "Installing Homebrew packages"
                    brew bundle --file=./config/Brewfile
                    ;;
                port)
                    echo "Installing MacPorts packages"
                    _dotfiles_port_install
                    xargs -n 1 code --install-extension < ./config/vscode-extensions.txt
                    ;;
            esac
    
            echo "Installing npm global packages"
            cat ./config/npm-global.json | jq -r '.dependencies | keys[]' | xargs npm install -g

            echo "Installing composer global packages"
            composer global install

        )
    elif [[ "$1" == "upgrade" ]]; then
        echo "Upgrading global packages ($pm)"
        (
            case "$pm" in
                brew)
                    echo "Upgrading homebrew packages"
                    brew upgrade
                    ;;
                port)
                    echo "Upgrading MacPorts packages"
                    sudo /opt/local/bin/port selfupdate && sudo /opt/local/bin/port upgrade outdated
                    ;;
            esac

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


