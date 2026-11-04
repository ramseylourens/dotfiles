# Aliases for php and pecl versions
# MacPorts already provides phpXY binaries in /opt/local/bin, so only Homebrew needs aliases
if [[ "$DOTFILES_PM" == "brew" ]]; then
    for v in 70 71 72 73 74 80 81 82 83 84 85; do
        alias php$v="$PKG_PREFIX/opt/php@${v[1]}.${v[2]}/bin/php"
        alias pecl$v="$PKG_PREFIX/opt/php@${v[1]}.${v[2]}/bin/pecl"
    done
    unset v
fi

# Nginx
alias nginxreload="sudo nginx -s reload"
alias nginxrestart="sudo nginx -s stop && sudo nginx"
alias cnginx="code $NGINX_DIR"
alias nginxlist="ll $NGINX_DIR/servers"

# Sites
alias sites="cd ~/Sites && ls -1"
alias sramsey="cd ~/Sites/ramseylourens"
alias cramsey="code ~/Sites/ramseylourens"
alias sjournler="cd ~/Sites/journler"
alias cjournler="code ~/Sites/journler"

# Code
alias code="code ."
alias codes="cd ~/Code && ls -1"

# Composer
alias c="composer"
alias cdev="c run dev"
alias cbuild="c run build"

# Laravel
alias a="php artisan"
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias octane="php artisan octane:start --server=roadrunner --watch"

# Zshrc
alias szsh="source ~/.zshrc"
alias czsh="code ~/Library/Mobile Documents/com~apple~CloudDocs/dotfiles/"

# Git
alias ec="git commit --allow-empty -m 'force redeploy'"

# Mongodb
function mongodbservice() {
    if [[ "$DOTFILES_PM" == "port" ]]; then
        sudo port load mongodb
    else
        launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/homebrew.mxcl.mongodb-community.plist
    fi
}

# SwimTechNL
alias transipssh="ssh ramsey@149.210.177.254"
