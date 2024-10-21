#!/bin/bash

function check_homebrew {
  if ! command -v brew &> /dev/null
  then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew is already installed."
  fi
}

function install_rbenv {
  if ! command -v rbenv &> /dev/null
  then
    echo "Installing rbenv..."
    brew install rbenv
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zshrc
    source ~/.zshrc
  else
    echo "rbenv is already installed."
  fi
}

function install_ruby {
  if [ -f ".ruby-version" ]; then
    ruby_version=$(cat .ruby-version)
    echo ".ruby-version file found. Using Ruby version: $ruby_version"
  else
    echo ".ruby-version file not found. Installing latest stable Ruby version."
    ruby_version=$(rbenv install -l | grep -v - | tail -1)
  fi

  if rbenv versions | grep -q "$ruby_version"; then
    echo "Ruby $ruby_version is already installed."
  else
    echo "Installing Ruby $ruby_version..."
    rbenv install $ruby_version
  fi

  rbenv global $ruby_version
  echo "Ruby version set to $(ruby -v)"
}

function install_redis {
  if ! command -v redis-server &> /dev/null
  then
    echo "Installing Redis..."
    brew install redis
    echo "Starting Redis service..."
    brew services start redis
  else
    echo "Redis is already installed and running."
  fi
}

function install_rails {
  if ! gem list -i '^rails$' &> /dev/null
  then
    echo "Rails not found. Installing Rails..."
    gem install rails
  else
    echo "Rails is already installed."
  fi
}

echo "Setting up your development environment..."

check_homebrew
brew update --auto-update
install_rbenv
install_ruby
install_redis
install_rails

echo "Setup complete. Your environment is ready with Ruby $(ruby -v) and Redis running!"

echo "Installing Gems..."
bundle install
