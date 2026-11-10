#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================================="
echo "        RECREATING COMPLETE DEVELOPMENT ENVIRONMENT      "
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

# 4. GNU Stow Symlink Engine deployment
echo "--> Deploying terminal configurations and text editor symlinks via Stow..."
# Navigate to the script's home location to ensure stow maps directories correctly
cd "$(dirname "$0")"

# Backup or clear existing loose configurations to prevent stow target blockages
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak 2>/dev/null || true
[ -f ~/.vimrc ] && rm -f ~/.vimrc

# Automatically drop the symlink shortcuts from the repository directly into your home folder
stow bash
stow tmux
stow vim
stow clangd

# 5. Native YouCompleteMe C++ Core Engine Compilations
echo "--> Cloning and compiling the YouCompleteMe C++ engine..."
YCM_DIR="$HOME/.vim/pack/plugins/start/YouCompleteMe"

# Wipe any corrupt partial installations if they exist, then clone fresh from source
if [ -d "$YCM_DIR" ]; then
    echo "Existing YCM directory found. Refreshing codebase..."
    rm -rf "$YCM_DIR"
fi

# Clone the engine directly from the verified official repository location
git clone --recursive https://github.com/ycm-core/YouCompleteMe "$YCM_DIR"

# Step inside and execute the python build script utilizing the clangd flag
cd "$YCM_DIR"
python3 install.py --clangd-completer

echo "========================================================="
echo "   RESTORATION COMPLETE! ENVIRONMENT SECURE AND READY   "
echo "========================================================="

