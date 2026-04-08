function phpv() {
    brew unlink php
    brew-php-switcher "$1" -s=valet,apache
    php -v
}

# nginxcreate text.x  /Users/yourname/Code/laravel/public/
function nginxcreate() {
    wget https://gist.githubusercontent.com/ramseylourens/e67e8338c59e91828e2c6bc045a74b18/raw/ba4b2fb7ff72a80e1e6a6ef65c5e30b84ef1d50c/nginx-server-template-m1.conf -O /usr/local/etc/nginx/servers/$1.conf
    sed -i '' "s:{{host}}:$1:" /usr/local/etc/nginx/servers/$1.conf

    if [ "$2" ]; then
        sed  -i '' "s:{{root}}:$2:" /usr/local/etc/nginx/servers/$1.conf
    else
        sed  -i '' "s:{{root}}:$HOME/Sites/$1:" /usr/local/etc/nginx/servers/$1.conf
    fi

    nginxaddssl $1

    nginxrestart

    code /usr/local/etc/nginx/servers/$1.conf
 }

 function nginxaddssl() {
     openssl req \
        -x509 -sha256 -nodes -newkey rsa:2048 -days 3650 \
        -subj "/CN=$1" \
        -reqexts SAN \
        -extensions SAN \
        -config <(cat /System/Library/OpenSSL/openssl.cnf; printf "[SAN]\nsubjectAltName=DNS:$1") \
        -keyout /usr/local/etc/nginx/ssl/$1.key \
        -out /usr/local/etc/nginx/ssl/$1.crt

    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /usr/local/etc/nginx/ssl/$1.crt
 }

 function nginxedit() {
     code /usr/local/etc/nginx/servers/$1
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

