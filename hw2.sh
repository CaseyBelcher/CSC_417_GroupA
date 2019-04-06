#!/bin/bash
set -ex
\cd "$(dirname $0)/duo/src"

# Install nodejs
if ! command -v node; then
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt-get -y install nodejs
fi

# I know this is jank. Didn't want to clutter up src/
pushd team-a
npm i
popd
test -e node_modules || ln -s team-a/node_modules .

printf "\n\n\nTo test our program, run 'make dom', 'make bestrest', 'make super', ...\n\n"
../etc/ide