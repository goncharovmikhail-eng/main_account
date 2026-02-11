#!/bin/bash
set -euo pipefail

VAULT="/home/gysar/Obsidian"
BRANCH="main"
LOGFILE="/home/gysar/push_obsidian.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

{
log "=============================="
log "Старт push Obsidian"

cd "$VAULT" || {
    log "Ошибка: не удалось перейти в $VAULT"
    exit 1
}

if [[ -z $(git status --porcelain) ]]; then
    log "Нет изменений, выходим"
    exit 0
fi

log "Найдены изменения"

git add .
git commit -m "auto: $(date '+%Y-%m-%d %H:%M:%S')" || {
    log "Ошибка коммита"
    exit 1
}

log "Делаем pull --rebase"
git pull --rebase origin "$BRANCH" || {
    log "Ошибка pull --rebase"
    exit 1
}

log "Делаем push"
git push origin "$BRANCH" || {
    log "Ошибка push"
    exit 1
}

log "Успешно отправлено"

} >> "$LOGFILE" 2>&1

