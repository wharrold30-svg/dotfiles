#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================================="
echo "     DEPLOYING FULL ENVIRONMENT (STANDARD BUILD)         "
echo "========================================================="

# 1. Update system repositories and add the cutting-edge GCC 15 toolchain PPA
echo "--> Syncing system repositories..."
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update



# 2. Install all development tools, compilers, and core libraries
echo "--> Installing compilers, build systems, and development packages..."
sudo apt-get install -y \
    build-essential \
    gcc-15 \
    g++-15 \
    make \
    cmake \
    git \
    tmux \
    vim \
    stow \
    python3-dev \
    libcurl4-openssl-dev \
    libcrypto++-dev \
    libgtest-dev

# 3. Set GCC-15 / G++-15 as your default global system compilers
echo "--> Configuring system alternatives for GCC 15..."
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-15 100

# 4. Clear out loose configurations to prevent symlink blockages ahead of time
echo "--> Cleaning up old configuration files..."
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak 2>/dev/null || true
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.bak 2>/dev/null || true
[ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.bak 2>/dev/null || true

if [ -d "$HOME/.vim" ] && [ ! -L "$HOME/.vim" ]; then
    echo "Backing up existing loose ~/.vim directory to ~/.vim.bak..."
    mv "$HOME/.vim" "$HOME/.vim.bak"
fi

# Manually generate the expected internal directory tree so Git can clone cleanly
mkdir -p "$HOME/.vim/bundle"

# 5. Bootstrap Vundle Plugin Manager into standard bundle folder
echo "--> Bootstrapping Vundle runtime ecosystem..."
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
if [ ! -d "$VUNDLE_DIR" ]; then
    git clone https://github.com/VundleVim/Vundle.vim "$VUNDLE_DIR"
fi

# 6. Native YouCompleteMe C++ Core Engine Compilations
echo "--> Cloning and compiling the YouCompleteMe C++ engine..."
YCM_DIR="$HOME/.vim/bundle/YouCompleteMe"

if [ -d "$YCM_DIR" ]; then
    echo "Existing YCM directory found. Refreshing codebase..."
    rm -rf "$YCM_DIR"
fi

git clone --recursive https://github.com/ycm-core/YouCompleteMe "$YCM_DIR"

# 1. Purge legacy build states and clean leftover swap configurations
echo "--> Auditing system storage for orphaned virtual memory flags..."
if [ -f /swapfile ]; then
    echo "Found leftover /swapfile from a previous build cycle. Cleaning up safely..."
    sudo swapoff /swapfile 2>/dev/null || true
    sudo rm -f /swapfile
fi

# 2. Allocate and mount isolated staging swap block (4GB)
echo "--> Initializing 4GB temporary build staging swap..."
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile5

cd "$YCM_DIR"
python3 install.py --clangd-completer

#  Clean up temporary Swap footprint right after heavy processing concludes
echo "--> Demobilizing and stripping temporary swap blocks..."
sudo swapoff /swapfile
sudo rm -f /swapfile

# 7. GNU Stow Symlink Engine deployment (Moved here!)
echo "--> Deploying terminal configurations and text editor symlinks via Stow..."
cd "$HOME/dotfiles"
stow bash
stow tmux
stow vim
stow clangd

# 8. Automated Headless Vundle Plugin Installation
echo "--> Running automated headless installation for remaining Vundle plugins..."
vim -i NONE -c "PluginInstall" -c "qa"

echo "========================================================="
echo "   RESTORATION COMPLETE! ENVIRONMENT SECURE AND READY   "
echo "========================================================="

