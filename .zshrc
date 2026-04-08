export ZSH="$HOME/dotfiles"

ZSH_THEME="robbyrussell"

#### HELPERS ####
# Source all helper scripts under $ZSH_CONFIGS/helper
for helper in "$ZSH"/helpers/**/*.zsh(N); do
  source "$helper"
done

#### PLUGINS ####
# Source all plugins under $ZSH_CONFIGS/plugins
source "$ZSH/plugins/zsh-defer/zsh-defer.plugin.zsh"

for plugin in "$ZSH"/plugins/**/*.plugin.zsh(N); do
  zsh-defer source "$plugin"
done

# Something with the src folder for zsh-completions
fpath=("$ZSH/plugins/zsh-completions/src" $fpath)

#### THEME ####
source "$ZSH/themes/zsh/$ZSH_THEME.zsh-theme"

# Java Kotlin
export PATH="$JAVA_HOME/bin:$PATH"

# Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

# Android
export ANDROID_HOME=~/Library/Android/sdk

# Cocao Pods
export LC_ALL=en_US.UTF-8

# 
export PATH="$HOME/.local/bin:$HOME/.composer/vendor/bin:/Library/Frameworks/Python.framework/Versions/3.4:$HOME/.npm-global:$(npm config get prefix)/bin:${PATH}"

source ~/dotfiles/zsh/aliases.zsh
source ~/dotfiles/zsh/functions.zsh
