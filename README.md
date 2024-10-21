# Note
1. This project uses `rbenv` to setup ruby on your system

# Automatic Setup Guide
Make script executable and run:
```bash
  chmod +x setup.sh
  ./setup.sh
```
# To Run
1. Add Your Open Weather `API_KEY` to the .env file
   https://home.openweathermap.org/api_keys

2. Start Server and Sidekiq (separate terminals)
   ```bash
    rails s
    bundle exec sidekiq
    ```
3. Run `rspec` to run the test suite

# Manual Setup Guide

This guide walks you through manually installing Homebrew, `rbenv`, Redis, and setting up Ruby as specified by the `.ruby-version` file.
This guide assumes you use zsh shell

---

## Step 1: Install Homebrew (if not already installed)

Homebrew is a package manager for macOS that simplifies installing and managing packages.

1. Open your terminal.
2. Check if Homebrew is installed:
   ```bash
    brew -v
   ```

If Homebrew is not installed, proceed with the following steps.

Install Homebrew by running:
    ```bash
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

After installation, add Homebrew to your environment:
    ```bash
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    ```bash

##  Step 2: Install rbenv and Ruby
1.  Install rbenv:
    ```bash
      brew install rbenv
    ```
2.  Add rbenv to your shell configuration:
    ```bash
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zshrc
    source ~/.zshrc
    ```
3. Set ruby version
    ```bash
      rbenv install $(cat .ruby-version)
      rbenv local $(cat .ruby-version)
    ```
##  Step 3: Install Redis

Install Redis via Homebrew:

```bash
  brew install redis
  brew services start redis
  redis-cli ping
```

You should get a response saying PONG if Redis is running correctly.
