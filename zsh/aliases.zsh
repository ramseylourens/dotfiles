# Aliases for php versions
alias php70="/usr/local/opt/php@7.0/bin/php" 
alias php71="/usr/local/opt/php@7.1/bin/php" 
alias php72="/usr/local/opt/php@7.2/bin/php" 
alias php73="/usr/local/opt/php@7.3/bin/php" 
alias php74="/usr/local/opt/php@7.4/bin/php" 
alias php80="/usr/local/opt/php@8.0/bin/php" 
alias php81="/usr/local/opt/php@8.1/bin/php" 
alias php82="/usr/local/opt/php@8.2/bin/php" 
alias php83="/usr/local/opt/php@8.3/bin/php" 
alias php84="/usr/local/opt/php@8.4/bin/php"
alias php85="/usr/local/opt/php@8.5/bin/php"

# Aliases for pecl versions
alias pecl70="/usr/local/opt/php@7.0/bin/pecl" 
alias pecl71="/usr/local/opt/php@7.1/bin/pecl" 
alias pecl72="/usr/local/opt/php@7.2/bin/pecl" 
alias pecl73="/usr/local/opt/php@7.3/bin/pecl" 
alias pecl74="/usr/local/opt/php@7.4/bin/pecl"
alias pecl80="/usr/local/opt/php@8.0/bin/pecl" 
alias pecl81="/usr/local/opt/php@8.1/bin/pecl" 
alias pecl82="/usr/local/opt/php@8.2/bin/pecl" 
alias pecl83="/usr/local/opt/php@8.3/bin/pecl" 
alias pecl84="/usr/local/opt/php@8.4/bin/pecl"
alias pecl85="/usr/local/opt/php@8.5/bin/pecl"

# Nginx
alias nginxreload="sudo nginx -s reload"
alias nginxrestart="sudo nginx -s stop && sudo nginx"
alias cnginx="code /usr/local/etc/nginx"
alias nginxlist="ll /usr/local/etc/nginx/servers"

# Sites
alias sites="cd ~/Sites"
alias sramsey="cd ~/Sites/ramseylourens"
alias cramsey="code ~/Sites/ramseylourens"
alias sjournler="cd ~/Sites/journler"
alias cjournler="code ~/Sites/journler"

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
