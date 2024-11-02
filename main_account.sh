#!/bin/bash

if ! stat /home/goncharov/.zshrc.pre-oh-my-zsh &> /dev/null; then
    echo "Zsh не найден, устанавливаем..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="3den"/' ~/.zshrc
else
    echo "Zsh уже установлен"
fi
read -p "Добавить SSH-ключи? (y/n): " add_keys

if [[ "$add_keys" == "y" || "$add_keys" == "Y" ]]; then
    chmod +x setup-ssh-keys.sh
    ./setup-ssh-keys.sh
fi
if ! grep -Fxq "source /home/$USER/life/alias.sh" ~/.bashrc; then
    echo 'source /home/$USER/life/main_account/alias.sh' >> ~/.bashrc
    echo 'source /home/$USER/life/main_account/alias.sh' >> ~/.zshrc
fi
if ! grep -Fxq "exec zsh" ~/.bashrc; then
    echo 'exec zsh' >> ~/.bashrc
fi
echo "Настройка завершена. Перезапустите терминал, чтобы применить изменения."
