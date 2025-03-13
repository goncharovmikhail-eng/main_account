#!/bin/bash  

if [ "$(id -u)" -ne 0 ]; then  
    echo "Этот скрипт должен быть запущен от пользователя root." >&2  
    exit 1  
fi  

if [[ "$1" == "-n" && -n "$2" ]]; then  
    USERNAME="$2"  
else  
    USERNAME="root"  
fi  

SSH_DIR="/home/"  
PUB_KEY="ваш_публичный_ключ"

if id "$USERNAME" &>/dev/null; then  
    echo "Пользователь $USERNAME существует. Сбрасываем пароль."  
    passwd -d "$USERNAME"  
else  
    echo "Пользователь $USERNAME не существует. Создаём его."  
    useradd -m "$USERNAME"   
    passwd -d "$USERNAME"  
fi  

USER_SSH_DIR="$SSH_DIR/$USERNAME/.ssh"  
if [ ! -d "$USER_SSH_DIR" ]; then  
    mkdir "$USER_SSH_DIR"  
    chown "$USERNAME:$USERNAME" "$USER_SSH_DIR"  
    chmod 700 "$USER_SSH_DIR"  
fi  

AUTHORIZED_KEYS_FILE="$USER_SSH_DIR/authorized_keys"  
if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then  
    touch "$AUTHORIZED_KEYS_FILE"  
    chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS_FILE"  
    chmod 700 "$AUTHORIZED_KEYS_FILE"  
fi  

echo "$PUB_KEY" >> "$AUTHORIZED_KEYS_FILE"  

SSHD_CONFIG="/etc/ssh/sshd_config"  
{  
    grep -q '^Port 22' "$SSHD_CONFIG" || echo 'Port 22'  
    grep -q '^PasswordAuthentication' "$SSHD_CONFIG" || echo 'PasswordAuthentication no'  
    grep -q '^PubkeyAuthentication' "$SSHD_CONFIG" || echo 'PubkeyAuthentication yes'  
} >> "$SSHD_CONFIG"  

sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' "$SSHD_CONFIG"  
sed -i 's/^PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSHD_CONFIG"  

systemctl restart sshd  
grep -v '^\s*#' /etc/ssh/sshd_config  

visudo  
