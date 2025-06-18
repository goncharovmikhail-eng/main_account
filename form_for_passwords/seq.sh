#!/bin/bash

function install_gpg() {
    gpg --full-generate-key

    echo "default-cache-ttl 3600" > ~/.gnupg/gpg-agent.conf  # Кэш на 1 час
    echo "max-cache-ttl 21600" >> ~/.gnupg/gpg-agent.conf

    echo "gpgconf --kill gpg-agent && gpgconf --launch gpg-agent" >> ~/.zshrc
    echo "GPG setup complete."
}

function newsecret() {
    local file="/home/$USER/passwd"
    read -p "Repeat email: " email
    nano $file
    
    gpg --quiet --batch --yes --encrypt --recipient "$email" --output "$file.gpg" "$file"
    
    shred -u "$file"
    chmod 700 "$file.gpg"
    
    echo "The file $file.gpg was created with permissions 700 and cannot be deleted."
}

function set_aliases() {
    echo "source $PWD/seq_aliases.sh" >> "/home/$USER/.zshrc"
    echo "Aliases added to .zshrc."
}

read -p "Generate new GPG key? (y/n) " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    install_gpg
fi

read -p "Add a new file for passwd? (y/n) " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    newsecret
fi

read -p "Add seq_aliases? (y/n) " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    set_aliases
fi
echo "use reset for update"
