#!/usr/bin/env bash

set -e

echo -n "Enter an email address to set up your ssh key and press [ENTER]:"
read email

echo "Generating a new ssh key..."
ssh-keygen -t rsa -b 4096 -C "$email"
echo "Done.\n"

echo "Adding the SSH key to the ssh-agent..."
eval "$(ssh-agent -s)"
printf '%s\n' '' 'Host *' ' AddKeysToAgent yes' ' UseKeychain yes' ' IdentityFile ~/.ssh/id_rsa' >> ~/.ssh/config
