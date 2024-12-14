#!/bin/bash
source ~/passwd_variable.sh
echo "Обновляем и апгрейдим систему"
sudo apt update && sudo apt upgrade
if ! stat /home/goncharov/.zshrc.pre-oh-my-zsh &> /dev/null; then
    echo "Zsh не найден, устанавливаем..."
    sudo apt update
    sudo apt install -y zsh
    echo "Настраиваем..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="3den"/' ~/.zshrc
else
    echo "Zsh уже установлен"
fi
sudo apt install ansible
echo "Устанавливаем Ansible"

read -p "Добавить SSH-ключи (рекомендуется после смены оболочки на zsh)? (y/n): " add_keys

if [[ "$add_keys" == "y" || "$add_keys" == "Y" ]]; then
    chmod +x setup-ssh-keys.sh
    ./setup-ssh-keys.sh
fi
if ! grep -Fxq "exec zsh" ~/.bashrc; then
    echo 'exec zsh' >> ~/.bashrc
fi

read -p "Запустить yc_install.sh? (y/n): " run_yc_install
if [[ "$run_yc_install" == "y" || "$run_yc_install" == "Y" ]]; then
    chmod +x yc_install.sh
    ./yc_install.sh
else
    echo "Пропущен запуск yc_install.sh"
fi

less ~/.zshrc
read -p "Install docker? " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    chmod +x docker-install.sh
    ./docker-install.sh
else
    echo "docker pass"
fi

read -p "install s3cmd? " answer

if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    chmod +x s3cmd.sh
    ./s3cmd.sh
else
    echo "s3cmd pass"
fi

read -p "gpg setting? " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    read -p "generate new gpg-key? " answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        gpg --full-generate-key
    fi
    echo "default-cache-ttl 3600" > ~/.gnupg/gpg-agent.conf  # Кэш на 1 час
    echo "max-cache-ttl 21600" >> ~/.gnupg/gpg-agent.conf
    echo "gpgconf --kill gpg-agent" >> ~/.zshrc
    echo "gpgconf --launch gpg-agent" >> ~/.zshrc
else
    echo "gpg pass"
fi
pip install --upgrade cryptography pyOpenSSL
pip install --upgrade ansible

echo "Настройка завершена. Перезапустите терминал, чтобы применить изменения."
