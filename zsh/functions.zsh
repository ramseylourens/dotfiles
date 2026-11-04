function phpv() {
    if [[ "$DOTFILES_PM" == "port" ]]; then
        # Accepts 8.4 or 84
        sudo port select --set php "php${1//./}"
    else
        brew unlink php
        brew-php-switcher "$1" -s=valet,apache
    fi
    php -v
}

# nginxcreate text.x  /Users/yourname/Code/laravel/public/
function nginxcreate() {
    wget https://gist.githubusercontent.com/ramseylourens/e67e8338c59e91828e2c6bc045a74b18/raw/ba4b2fb7ff72a80e1e6a6ef65c5e30b84ef1d50c/nginx-server-template-m1.conf -O $NGINX_DIR/servers/$1.conf
    sed -i '' "s:{{host}}:$1:" $NGINX_DIR/servers/$1.conf

    if [ "$2" ]; then
        sed  -i '' "s:{{root}}:$2:" $NGINX_DIR/servers/$1.conf
    else
        sed  -i '' "s:{{root}}:$HOME/Sites/$1:" $NGINX_DIR/servers/$1.conf
    fi

    nginxaddssl $1

    nginxrestart

    code $NGINX_DIR/servers/$1.conf
 }

 function nginxaddssl() {
     openssl req \
        -x509 -sha256 -nodes -newkey rsa:2048 -days 3650 \
        -subj "/CN=$1" \
        -reqexts SAN \
        -extensions SAN \
        -config <(cat /System/Library/OpenSSL/openssl.cnf; printf "[SAN]\nsubjectAltName=DNS:$1") \
        -keyout $NGINX_DIR/ssl/$1.key \
        -out $NGINX_DIR/ssl/$1.crt

    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $NGINX_DIR/ssl/$1.crt
 }

 function nginxedit() {
     code $NGINX_DIR/servers/$1
 }

function setup() {
    ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/dotfiles/ ~/dotfiles
}

# Ramseylourens.com autogit push
# Also pulls the theme from the appropiate repository
# https://github.com/ramseylourens/ramsey-lourens.git

# Sites
function pramsey() {
    (

        cd ~/Sites/ramseylourens.test || return
        echo "📤 Pushing to all remotes..."
        git push transip && echo "✅ Done!" || echo "❌ Push failed"
    )
}

