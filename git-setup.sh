#!/usr/bin/env bash

# TODO capture filename for these subsequent steps:
# - ssh-add 
# - editing the config
# - copying to github
set -e

echo -n "Enter an email address to set up your ssh key and press [ENTER]:"
read email

echo "Generating a new ssh key..."
ssh-keygen -t rsa -b 4096 -C "$email"
echo "Done.\n"

echo "Adding the SSH key to the ssh-agent..."
eval "$(ssh-agent -s)"
printf '%s\n' '' 'Host *' ' AddKeysToAgent yes' ' UseKeychain yes' ' IdentityFile ~/.ssh/id_rsa' >> ~/.ssh/config
ssh-add -K ~/.ssh/id_rsa

echo "Copy id_rsa.pub to your clipboard and open github settings page to add it?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) pbcopy < ~/.ssh/id_rsa.pub; open "https://github.com/settings/keys"; break;;
        No ) echo "You have chosen to add the key to github later. Goodbye."; exit;;
    esac
done
	