#!/bin/bash

LOG_FILE="$(dirname "$(realpath "$0")")/script.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

if [ "$(id -u)" -ne 0 ]; then
    log "Этот скрипт должен быть запущен от пользователя root."
    echo "Ошибка: требуется root." >&2
    exit 1
fi

USERNAME="root"
PUB_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6YQpJ61F6M82pgMHEJcMEKpjOIBdZ1pOg1NtC6UNeO goncharov@PC037"
RESET_PASSWORD=false
DO_UPDATE=false
DO_REBOOT=false

while getopts ":u:k:pUr" opt; do
    case $opt in
        u) USERNAME="$OPTARG" ;;
        k) PUB_KEY="$OPTARG" ;;
        p) RESET_PASSWORD=true ;;
        U) DO_UPDATE=true ;;
        r) DO_REBOOT=true ;;
        \?) log "Неверный флаг: -$OPTARG"
            echo "Ошибка: неправильный флаг." >&2
            exit 1 ;;
        :) log "Флаг -$OPTARG требует аргумент."
            echo "Ошибка: отсутствует аргумент." >&2
            exit 1 ;;
    esac
done

if [ "$USERNAME" == "root" ]; then
    USER_SSH_DIR="/root/.ssh"
else
    USER_SSH_DIR="/home/$USERNAME/.ssh"
fi

if id "$USERNAME" &>/dev/null; then
    log "Пользователь $USERNAME существует."
    if $RESET_PASSWORD; then
        log "Сбрасываем пароль пользователя $USERNAME."
        passwd -d "$USERNAME" >> "$LOG_FILE"
    fi
else
    log "Создаем пользователя $USERNAME."
    useradd -m "$USERNAME"
    if $RESET_PASSWORD; then
        passwd -d "$USERNAME"
    fi
fi

if [ ! -d "$USER_SSH_DIR" ]; then
    mkdir -p "$USER_SSH_DIR"
    chown "$USERNAME:$USERNAME" "$USER_SSH_DIR"
    chmod 700 "$USER_SSH_DIR"
fi

AUTHORIZED_KEYS_FILE="$USER_SSH_DIR/authorized_keys"
if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then
    touch "$AUTHORIZED_KEYS_FILE"
    chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS_FILE"
    chmod 600 "$AUTHORIZED_KEYS_FILE"
fi

if ! grep -qF "$PUB_KEY" "$AUTHORIZED_KEYS_FILE"; then
    echo "$PUB_KEY" >> "$AUTHORIZED_KEYS_FILE"
    log "Добавлен публичный ключ для пользователя $USERNAME."
else
    log "Публичный ключ уже существует для пользователя $USERNAME."
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
{
    grep -q '^Port 22' "$SSHD_CONFIG" || echo 'Port 22'
    grep -q '^PasswordAuthentication' "$SSHD_CONFIG" || echo 'PasswordAuthentication yes'
    grep -q '^PubkeyAuthentication' "$SSHD_CONFIG" || echo 'PubkeyAuthentication yes'
} >> "$SSHD_CONFIG"

sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD_CONFIG"
sed -i 's/^PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSHD_CONFIG"

if systemctl restart sshd; then
    log "Служба sshd перезапущена."
else
    log "Ошибка при перезапуске sshd."
    echo "Ошибка при перезапуске sshd." >&2
    exit 1
fi

grep -v '^\s*#' /etc/ssh/sshd_config >> "$LOG_FILE"

mkdir -p /etc/sudoers.d/
SUDOERS_FILE="/etc/sudoers.d/99-custom-sudo"
if [ ! -f "$SUDOERS_FILE" ]; then
    touch "$SUDOERS_FILE"
fi

echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> "$SUDOERS_FILE"
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> "$SUDOERS_FILE"
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

SELINUX_CONFIG="/etc/selinux/config"
if grep -q "^SELINUX=" "$SELINUX_CONFIG"; then
    sed -i 's/^SELINUX=.*/SELINUX=permissive/' "$SELINUX_CONFIG"
else
    echo "SELINUX=permissive" >> "$SELINUX_CONFIG"
fi

# Проверка на Astra Linux
if [ -f /etc/astra_version ]; then
    log "Обнаружена Astra Linux, настраиваем репозитории."
    cat > /etc/apt/sources.list <<EOF
deb https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-main/ 1.7_x86-64 main contrib non-free
deb https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-update/ 1.7_x86-64 main contrib non-free
deb https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 main contrib non-free astra-ce
EOF
    log "Файл /etc/apt/sources.list успешно перезаписан."
fi

if $DO_UPDATE; then
    log "Обновление системы."
    if command -v yum &>/dev/null; then
        yum update -y
    elif command -v apt &>/dev/null; then
        apt update -y
    else
        log "Неизвестный пакетный менеджер для обновления."
    fi
fi

log "Скрипт выполнен успешно."

if $DO_REBOOT; then
    log "Система будет перезагружена."
    echo "ОК — перезагрузка."
    reboot
else
    echo "ОК — без перезагрузки."
fi

