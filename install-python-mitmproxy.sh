#!/bin/bash

# Set -e so that if any command fails the script will exit immediately.
set -e

PYTHON_VERSION="3.7.2"
PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"

# Install requirements
sudo apt update
sudo apt-get -y install \
  libffi-dev \
  libbz2-dev \
  liblzma-dev \
  libsqlite3-dev \
  libncurses5-dev \
  libgdbm-dev \
  zlib1g-dev \
  libreadline-dev \
  libssl-dev \
  tk-dev \
  build-essential \
  libncursesw5-dev \
  libc6-dev \
  openssl \
  git

# Download source
curl -o Python-${PYTHON_VERSION}.tgz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

# Extract source
tar -xzf Python-${PYTHON_VERSION}.tgz

# Configure and build Python 3.7.2
cd Python-${PYTHON_VERSION}/
./configure --prefix=$HOME/.local
make -j -l 4
make install

# Add to path
echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.profile
source ~/.profile

# Install mitmproxy
pip3 install mitmproxy

# Cleanup
cd ../
rm -rf Python-${PYTHON_VERSION}
rm Python-${PYTHON_VERSION}.tgz
