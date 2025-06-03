#!/bin/bash  

LOG_FILE="$(dirname "$(realpath "$0")")/script.log"  

# Функция для записи сообщений в лог-файл  
log() {  
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"  
}  

if [ "$(id -u)" -ne 0 ]; then  
    log "Этот скрипт должен быть запущен от пользователя root."  
    echo "Ошибка." >&2  
    exit 1  
fi  

USERNAME="root"  
PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6YQpJ61F6M82pgMHEJcMEKpjOIBdZ1pOg1NtC6UNeO goncharov@PC037"  

while getopts ":u:k:" opt; do  
    case $opt in  
        u) USERNAME="$OPTARG" ;;  
        k) PUB_KEY="$OPTARG" ;;  
        \?) log "Неверный флаг: -$OPTARG"  
            echo "Ошибка." >&2; exit 1 ;;  
        :) log "Флаг -$OPTARG требует аргумент."  
            echo "Ошибка." >&2; exit 1 ;;  
    esac  
done  

# Устанавливаем путь к .ssh в зависимости от пользователя  
if [ "$USERNAME" == "root" ]; then  
    USER_SSH_DIR="/root/.ssh"  
else  
    USER_SSH_DIR="/home/$USERNAME/.ssh"  
fi  

if id "$USERNAME" &>/dev/null; then  
    log "Пользователь $USERNAME существует. Сбрасываем пароль."  
    passwd -d "$USERNAME" >> $LOG_FILE 
else  
    log "Пользователь $USERNAME не существует. Создаём его."  
    useradd -m "$USERNAME"   
    passwd -d "$USERNAME"  
fi  

if [ ! -d "$USER_SSH_DIR" ]; then  
    mkdir "$USER_SSH_DIR"  
    chown "$USERNAME:$USERNAME" "$USER_SSH_DIR"  
    chmod 700 "$USER_SSH_DIR"  
fi  

AUTHORIZED_KEYS_FILE="$USER_SSH_DIR/authorized_keys"  
if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then  
    touch "$AUTHORIZED_KEYS_FILE"  
    chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS_FILE"  
    chmod 600 "$AUTHORIZED_KEYS_FILE"  
fi  

# Проверяем, существует ли уже ключ в authorized_keys  
if ! grep -qF "$PUB_KEY" "$AUTHORIZED_KEYS_FILE"; then  
    echo "$PUB_KEY" >> "$AUTHORIZED_KEYS_FILE"  
    log "Добавлен публичный ключ для пользователя $USERNAME."  
else  
    log "Публичный ключ уже существует для пользователя $USERNAME."  
fi  

SSHD_CONFIG="/etc/ssh/sshd_config"  
{  
    grep -q '^Port 22' "$SSHD_CONFIG" || echo 'Port 22'  
    grep -q '^PasswordAuthentication' "$SSHD_CONFIG" || echo 'PasswordAuthentication no'  
    grep -q '^PubkeyAuthentication' "$SSHD_CONFIG" || echo 'PubkeyAuthentication yes'  
} >> "$SSHD_CONFIG"  

sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' "$SSHD_CONFIG"  
sed -i 's/^PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSHD_CONFIG"  

if systemctl restart sshd; then  
    log "Служба sshd перезапущена."  
else  
    log "Не удалось перезапустить службу sshd."  
    echo "Ошибка." >&2; exit 1  
fi  

# Убедимся, что все изменения применились  
grep -v '^\s*#' /etc/ssh/sshd_config >> "$LOG_FILE"  

mkdir -p /etc/sudoers.d/
# Создаем файл для конфигурации sudoers, если он еще не существует  
FILE="/etc/sudoers.d/99-custom-sudo"  
if [ ! -f "$FILE" ]; then  
    touch "$FILE"  
fi  

# Добавляем строку для пользователя goncharov  
echo "goncharov ALL=(ALL) NOPASSWD: ALL" | sudo tee -a "$FILE"  

# Добавляем строку для группы wheel  
echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee -a "$FILE"  

# Установим правильные права на файл  
sudo chmod 440 "$FILE"
SELINUX_CONFIG="/etc/selinux/config" 
if grep -q "^SELINUX=" "$SELINUX_CONFIG"; then  
    sed -i 's/^SELINUX=.*/SELINUX=permissive/' "$SELINUX_CONFIG"  
else  
    echo "SELINUX=permissive" >> "$SELINUX_CONFIG"  
fi
sudo yum update -y || sudo apt update -y
echo "ОК"  
sudo reboot
