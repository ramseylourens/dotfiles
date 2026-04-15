function dotfiles() {
    if [[ "$1" == "sync" ]]; then
    echo "sync mode"
    # parse the json and reinstall

    # npm 
    # npm list -g --depth=0 --json > npm-global.json
    # cat npm-global.json | jq -r '.dependencies | keys[]' | xargs npm install -g

    # composer
    # symlink config/composer.json to ~/.composer/composer.json
    # cat ~/.composer/composer.json  # shows what's globally installed
    # composer global install        # reinstalls from ~/.composer/composer.json
  else
    echo "List of commands"
  fi
}


