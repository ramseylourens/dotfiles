#!/usr/bin/env zsh
# Usage: ./setup.sh [--dry-run]
# DOTFILES_PM=brew|port forces a package manager, otherwise it is detected per machine.

DRY_RUN=0
INSTALL_SYNC_APP_ONLY=0
for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=1
    [[ "$arg" == "--install-sync-app" ]] && INSTALL_SYNC_APP_ONLY=1
done

# Runs a command, or only prints it with --dry-run
run() {
    if (( DRY_RUN )); then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* || "$(uname -s)" == CYGWIN* || "$(uname -s)" == "Windows_NT" ]]; then
    echo "This script requires macOS or Linux. Run .\\setup.ps1 for Windows." >&2
    exit 1
fi

source "${0:A:h}/helpers/platform.zsh"
echo -e "\033[33mPackage manager: $DOTFILES_PM (prefix $PKG_PREFIX)\033[0m"

# Prints the MacPorts installer url for the running macOS version
macports_pkg_url() {
    local version="${MACPORTS_VERSION:-2.12.7}"
    local macos="$(sw_vers -productVersion)" name
    case "${macos%%.*}" in
        10) [[ "$macos" == 10.15* ]] && name="10.15-Catalina" ;;
        11) name="11-BigSur" ;;
        12) name="12-Monterey" ;;
        13) name="13-Ventura" ;;
        14) name="14-Sonoma" ;;
        15) name="15-Sequoia" ;;
        26) name="26-Tahoe" ;;
        27) name="27-GoldenGate" ;;
    esac

    if [[ -z "$name" ]]; then
        echo "No MacPorts installer known for macOS $macos" >&2
        return 1
    fi
    echo "https://github.com/macports/macports-base/releases/download/v${version}/MacPorts-${version}-${name}.pkg"
}

install_with_brew() {
    if ! command -v brew &>/dev/null; then
    	echo -e "\033[33mInstalling Homebrew\033[0m"
    	# This URL fetches the true, official architecture-agnostic installer
    	run ./brew.sh

    	run brew install npm
    	run brew install --cask google-chrome
    	run brew install --cask iterm2
    fi

    if [ -f ~/dotfiles/config/Brewfile ]; then
        echo -e "\033[33mBrewfile exists downloading and installing your configuration\033[0m"
        run brew bundle --file=~/dotfiles/config/Brewfile --verbose || true

        # Symlink Mongodb conf
        run ln -sf ~/dotfiles/config/mongod.conf "$PKG_PREFIX/etc/mongod.conf"

        # Symlink MySQL conf
        run ln -sf ~/dotfiles/config/my.cnf ~/.my.cnf

        # Setup MySQL
        run mysql_secure_installation

        # Setup Mkcert?
        run mkcert -install
    fi
}

install_with_macports() {
    if [[ ! -x /opt/local/bin/port ]]; then
        echo -e "\033[33mInstalling MacPorts\033[0m"
        local url pkg="${TMPDIR:-/tmp}/macports.pkg"
        url="$(macports_pkg_url)" || return 1
        run curl -fL "$url" -o "$pkg"
        run sudo installer -pkg "$pkg" -target /
    fi
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

    echo -e "\033[33mUpdating MacPorts\033[0m"
    run sudo port selfupdate

    if [ -f ~/dotfiles/config/macports.txt ]; then
        echo -e "\033[33mInstalling ports from macports.txt\033[0m"
        local line failed=()
        while IFS= read -r line; do
            [[ -z "$line" || "$line" == \#* ]] && continue
            run sudo port install ${=line} || failed+=("$line")
        done < ~/dotfiles/config/macports.txt
        (( ${#failed} )) && echo -e "\033[31mFailed ports: ${failed[*]}\033[0m"

        run sudo port select --set php php84
        run sudo port select --set ruby ruby33

        # Not available as ports
        if ! command -v composer &>/dev/null; then
            run mkdir -p ~/.local/bin
            run zsh -c 'curl -sS https://getcomposer.org/installer | php -- --install-dir="$HOME/.local/bin" --filename=composer'
        fi
        run sudo gem install cocoapods

        if command -v code &>/dev/null && [ -f ~/dotfiles/config/vscode-extensions.txt ]; then
            run zsh -c 'xargs -n 1 code --install-extension < ~/dotfiles/config/vscode-extensions.txt'
        fi
        # Symlink MySQL conf
        run ln -sf ~/dotfiles/config/my.cnf ~/.my.cnf

        run mkcert -install
        echo -e "\033[33mMongoDB, MySQL and PostgreSQL servers need a one-time init, see the Readme\033[0m"
    fi

    echo -e "\033[33mCasks and Mac App Store apps are not in MacPorts, install them manually (see Readme)\033[0m"
}

install_dotfiles_sync_app() {
    local desktop="${0:A:h}/apps/DotfilesSync/desktop"
    local os="$(uname -s)"

    case "$os" in
        Darwin)
            local project="$desktop/macos/ReactNativeStarter.xcodeproj"
            local derived="${TMPDIR:-$HOME/.cache}/dotfiles-sync-derived"
            local app="$derived/Build/Products/Release/DotfilesSync.app"

            if (( DRY_RUN )); then
                echo "[dry-run] yarn --cwd \"$desktop\" install --frozen-lockfile"
                echo "[dry-run] yarn --cwd \"$desktop\" macos:pod:install"
                echo "[dry-run] xcodebuild -project \"$project\" -scheme ReactNativeStarter-macOS -configuration Release -derivedDataPath \"$derived\" CODE_SIGN_IDENTITY=- clean build"
                echo "[dry-run] ditto \"$app\" \"$HOME/Applications/DotfilesSync.app\""
                echo "[dry-run] open -a \"$HOME/Applications/DotfilesSync.app\""
                return
            fi

            command -v yarn >/dev/null || { echo "Yarn is required to build Dotfiles Sync." >&2; return 1; }
            command -v xcodebuild >/dev/null || { echo "Xcode is required to build Dotfiles Sync." >&2; return 1; }
            yarn --cwd "$desktop" install --frozen-lockfile || return 1
            yarn --cwd "$desktop" macos:pod:install || return 1
            xcodebuild -project "$project" \
                -scheme ReactNativeStarter-macOS \
                -configuration Release \
                -derivedDataPath "$derived" \
                CODE_SIGN_IDENTITY=- \
                clean build || return 1

            mkdir -p "$HOME/Applications"
            ditto "$app" "$HOME/Applications/DotfilesSync.app" || return 1
            open -a "$HOME/Applications/DotfilesSync.app"
            ;;
        Linux)
            local build_dir="$desktop/linux/dist"
            local app="$HOME/Applications/DotfilesSync.AppImage"
            local desktop_entry="$HOME/.local/share/applications/dotfiles-sync.desktop"

            if (( DRY_RUN )); then
                echo "[dry-run] yarn --cwd \"$desktop\" install --frozen-lockfile"
                echo "[dry-run] yarn --cwd \"$desktop\" linux:install"
                echo "[dry-run] yarn --cwd \"$desktop\" linux:build"
                echo "[dry-run] install the generated AppImage at \"$app\" and create \"$desktop_entry\""
                return
            fi

            command -v yarn >/dev/null || { echo "Yarn is required to build Dotfiles Sync." >&2; return 1; }
            yarn --cwd "$desktop" install --frozen-lockfile || return 1
            yarn --cwd "$desktop" linux:install || return 1
            yarn --cwd "$desktop" linux:build || return 1
            local artifacts=("$build_dir/"*.AppImage)
            if [[ ! -f "${artifacts[1]}" ]]; then
                echo "The Linux build did not produce an AppImage in $build_dir." >&2
                return 1
            fi

            mkdir -p "$HOME/Applications" "${desktop_entry:h}" || return 1
            cp -p "${artifacts[1]}" "$app" || return 1
            printf '[Desktop Entry]\nType=Application\nName=Dotfiles Sync\nComment=Synchronize dotfiles\nExec="%s"\nTerminal=false\nCategories=Utility;\n' "$app" > "$desktop_entry" || return 1
            echo "Installed Dotfiles Sync to $app"
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            echo "Run .\\setup.ps1 from PowerShell to build and install Dotfiles Sync on Windows." >&2
            return 1
            ;;
        *)
            echo "Dotfiles Sync desktop builds are not supported on $os." >&2
            return 1
            ;;
    esac
}

if (( INSTALL_SYNC_APP_ONLY )); then
    install_dotfiles_sync_app || exit 1
    exit 0
fi

echo -e "\033[33mChanging the default shell to /bin/zsh\033[0m"
run chsh -s /bin/zsh

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
    run ln -sfn ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/

    if ! xcode-select -p &>/dev/null; then
    	echo -e "\033[33mInstalling Xcode Command Line Interface Tools...\033[0m"
    	run xcode-select --install
    
    	# Pause and wait for user input
    	if (( ! DRY_RUN )); then
    	    echo -e "\033[36m👉 Complete the GUI installation popup, then press [ENTER] here to continue your dotfiles setup...\033[0m"
    	    read -r
    	fi
    fi

    if [[ "$DOTFILES_PM" == "port" ]]; then
        install_with_macports
    else
        install_with_brew
    fi

    echo -e "\033[33mBuilding and installing Dotfiles Sync in ~/Applications\033[0m"
    install_dotfiles_sync_app || exit 1

    if (( DRY_RUN )); then
        echo -e "\033[33mDry run finished, stopping before the composer, npm and repository steps\033[0m"
        exit 0
    fi

    if [ -f "$HOME/dotfiles/config/composer.json" ]; then
        cp "$HOME/dotfiles/config/composer.json" "$HOME/.composer/composer.json"
        composer global install

        ln -sf ~/dotfiles/nginx "$PKG_PREFIX/etc/nginx"

        if [[ "$DOTFILES_PM" == "brew" ]]; then
            valet install

            ln -sf ~/dotfiles/valet ~/.config/valet

            valet secure swimtech && valet secure waterfiets && valet secure api.swimtech

            valet restart
        else
            echo "Valet needs Homebrew, skipping. Sites are served by nginx from $PKG_PREFIX/etc/nginx"
        fi
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
