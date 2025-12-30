#!/bin/bash

function install_gpg() {
    gpg --full-generate-key

    # Настройка кэша пароля GPG
    echo "default-cache-ttl 43200" > ~/.gnupg/gpg-agent.conf  # 12 часов = 43200 секунд
    echo "max-cache-ttl 50400" >> ~/.gnupg/gpg-agent.conf    # 14 часов = 50400 секунд

    # Перезапуск агента GPG при старте терминала
    echo "gpgconf --kill gpg-agent && gpgconf --launch gpg-agent" >> ~/.zshrc
    echo "GPG setup complete. Password cache is set for 12 hours (max 48 hours)."
}

function newsecret() {

    local file="~/.seq/passwd"
    read -p "Repeat email: " email
    nano $file
    
    gpg --quiet --batch --yes --encrypt --recipient "$email" --output "$file.gpg" "$file"
    
    shred -u "$file"
    chmod 700 "$file.gpg"
    mkdir -p ~/.seq
    echo "The file $file.gpg was created with permissions 700 and cannot be deleted."
}

function set_aliases() {
    echo "source $PWD/seq_aliases.sh" >> "~/.zshrc"
    echo "source $PWD/seq_aliases.sh" >> "~/.bashrc"
    echo "Aliases added to .zshrc and .bashrc"
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
