#!/bin/bash
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
read -p "Добавить SSH-ключи (рекомендуется после смены оболочки на zsh)? (y/n): " add_keys

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

read -p "Запустить yc_install.sh? (y/n): " run_yc_install
if [[ "$run_yc_install" == "y" || "$run_yc_install" == "Y" ]]; then
    chmod +x yc_install.sh
    ./yc_install.sh
else
    echo "Пропущен запуск yc_install.sh"
fi

less ~/.zshrc
echo "Настройка завершена. Перезапустите терминал, чтобы применить изменения."
