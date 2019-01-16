#!/bin/bash
# Install pip, using the same strategy as described by the Ansible local provisioner docs.

command -v pip
if [ $? -ne 0 ]; then
    pushd /tmp

    curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    pip install -U pip

    $PIP_VERSION=$(pip --version)
    echo "install_pip.sh: pip $PIP_VERSION installed."
    popd
else
    echo "install_pip.sh: pip is already installed. Skipping."
fi
