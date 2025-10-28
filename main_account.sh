#!/bin/bash

# Определяем пакетный менеджер
if command -v apt >/dev/null 2>&1; then
    PKG_INSTALL="sudo apt install -y"
    PKG_UPDATE="sudo apt update"
elif command -v dnf >/dev/null 2>&1; then
    PKG_INSTALL="sudo dnf install -y"
    PKG_UPDATE="sudo dnf update -y"
else
    echo "Не найден поддерживаемый пакетный менеджер (apt или dnf)."
    exit 1
fi

# Выбор действия для обновления системы
echo "Выберите действие:"
echo "1) Только обновить списки пакетов (update)"
echo "2) Обновить и установить все обновления (upgrade)"
echo "s) Пропустить"
read -rp "Введите 1, 2 или s: " choice

case "$choice" in
    1)
        echo "Обновляем списки пакетов..."
        $PKG_UPDATE
        ;;
    2)
        echo "Обновляем систему..."
        $PKG_UPDATE
        if command -v apt >/dev/null 2>&1; then
            sudo apt upgrade -y
        else
            sudo dnf update -y
        fi
        ;;
    s|S)
        echo "Пропускаем обновление системы."
        ;;
    *)
        echo "Неверный выбор. Пропускаем."
        ;;
esac

# Функция установки Zsh + Oh My Zsh
install_zsh() {
    echo "Zsh не найден. Установить? (y/n/s)"
    read -r zsh_choice
    case "$zsh_choice" in
        y|Y)
            echo "Устанавливаем Zsh..."
            $PKG_UPDATE
            $PKG_INSTALL zsh curl
            echo "Настраиваем Oh My Zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
            sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="3den"/' ~/.zshrc
            echo "Zsh установлен и настроен."
            ;;
        n|N|s|S)
            echo "Пропускаем установку Zsh."
            ;;
        *)
            echo "Неверный выбор. Пропускаем Zsh."
            ;;
    esac
}

# Проверка Zsh
if ! stat ~/.zshrc.pre-oh-my-zsh &> /dev/null; then
    install_zsh
else
    echo "Zsh уже установлен."
fi

# Функция установки Ansible
install_ansible() {
    echo "Хотите установить Ansible? (y/n/s)"
    read -r ansible_choice
    case "$ansible_choice" in
        y|Y)
            echo "Устанавливаем Ansible..."
            $PKG_UPDATE
            $PKG_INSTALL ansible
            echo "Ansible установлен."
            ;;
        n|N|s|S)
            echo "Пропускаем установку Ansible."
            ;;
        *)
            echo "Неверный выбор. Пропускаем Ansible."
            ;;
    esac
}

# Проверка Ansible
if ! command -v ansible >/dev/null 2>&1; then
    install_ansible
else
    echo "Ansible уже установлен."
fi

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
