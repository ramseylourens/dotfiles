export ZSH="$HOME/dotfiles/oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

source ~/dotfiles/zsh/aliases.zsh
source ~/dotfiles/zsh/functions.zsh

export PATH="$HOME/.local/bin:$HOME/.composer/vendor/bin:/Library/Frameworks/Python.framework/Versions/3.4:${PATH}"
