#!/bin/bash

DEB_BASED=("ubuntu" "debian" "pop")
RPM_BASED=("fedora")

LINUX_OS=$(less /etc/os-release | grep "^ID=" | sed 's/ID=//')

echo "Making 'scripts/' executable"
chmod -R +x scripts

case "$(uname -s)" in
    Linux*)
      if [[ " ${DEB_BASED[@]} " =~ " $LINUX_OS " ]]; then
        echo "Installing .deb dependencies..."
        sudo apt install docker.io
      fi

      if [[ " ${RPM_BASED[@]} " =~ " $LINUX_OS " ]]; then
          echo "Installing docker..."
          sudo dnf -y install dnf-plugins-core
          sudo dnf config-manager \
            --add-repo \
            https://download.docker.com/linux/fedora/docker-ce.repo
          echo "Installing .rpm dependencies"
          sudo dnf install docker-ce docker-ce-cli containerd.io
      fi

      sudo systemctl start docker;;
    Darwin*)
      if [ -z "$(command -v brew)" ]; then
        echo "Either you still don't have brew installed, or something else has gone wrong. Time to ask for help."
      else
        echo "Installing dependencies with Homebrew"
        if [[ ! -e /Applications/Docker.app ]]; then
            HOMEBREW_NO_AUTO_UPDATE=1 brew cask install docker
        fi
        echo "Ensuring Docker is running"
        open -gj -a /Applications/Docker.app
      fi;;
    *)
      echo "Can't match OS - please install Docker";;
esac

echo "You're all set!"
