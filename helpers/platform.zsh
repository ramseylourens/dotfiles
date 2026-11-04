# Machine and package manager detection.
# Exports DOTFILES_PM (brew|port) and PKG_PREFIX. Set DOTFILES_PM before
# sourcing to force one. Sourced by .zshrc (helpers glob) and setup.sh.

# MacBook Pro 2013-2015 Retina models run on OpenCore Legacy Patcher and use MacPorts
function _dotfiles_is_legacy_mac() {
    [[ "$(sysctl -n hw.model 2>/dev/null)" == MacBookPro11,* ]]
}

function _dotfiles_has_brew() {
    command -v brew &>/dev/null || [[ -x /opt/homebrew/bin/brew || -x /usr/local/bin/brew ]]
}

function _dotfiles_has_port() {
    command -v port &>/dev/null || [[ -x /opt/local/bin/port ]]
}

# Package manager this machine should use
function _dotfiles_detect_pm() {
    if _dotfiles_is_legacy_mac; then
        echo "port"
    elif _dotfiles_has_brew; then
        echo "brew"
    elif _dotfiles_has_port; then
        echo "port"
    else
        echo "brew"
    fi
}

export DOTFILES_PM="${DOTFILES_PM:-$(_dotfiles_detect_pm)}"

if [[ "$DOTFILES_PM" == "port" ]]; then
    export PKG_PREFIX="/opt/local"
    [[ ":$PATH:" != *":/opt/local/bin:"* ]] && export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
else
    _brew_bin="$(command -v brew 2>/dev/null)"
    if [[ -z "$_brew_bin" ]]; then
        for _brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            [[ -x "$_brew_bin" ]] && break
            _brew_bin=""
        done
    fi

    if [[ -n "$_brew_bin" ]]; then
        export PKG_PREFIX="${_brew_bin:h:h}"
    elif [[ "$(uname -m)" == "arm64" ]]; then
        export PKG_PREFIX="/opt/homebrew"
    else
        export PKG_PREFIX="/usr/local"
    fi
    unset _brew_bin
fi

export NGINX_DIR="$PKG_PREFIX/etc/nginx"

# svc start|stop|restart <name>: manage a background service with the active package manager
function svc() {
    local action="$1" name="$2"
    if [[ -z "$action" || -z "$name" ]]; then
        echo "Usage: svc start|stop|restart <service>"
        return 1
    fi

    if [[ "$DOTFILES_PM" == "port" ]]; then
        case "$action" in
            start)   sudo port load "$name" ;;
            stop)    sudo port unload "$name" ;;
            restart) sudo port unload "$name"; sudo port load "$name" ;;
            *)       echo "Unknown action: $action"; return 1 ;;
        esac
    else
        brew services "$action" "$name"
    fi
}
