#general
aliasw() {
    nano "$HOME/main_account/alias.sh" || return
    source "$HOME/main_account/alias.sh"
    echo "Aliases reloaded"
}

cl() {
  echo '' > "$1" && vim "$1"
}

drmallimg() {
    images=$(docker images -aq)
    if [ -n "$images" ]; then
        docker rmi -f $images
    else
        echo "No images to remove"
    fi
}


drmall() {
    docker ps -aq | xargs -r docker rm -f
}

alias dps="docker ps -a"
alias vin_clean='find . -type f -name "*:Zone.Identifier*" -delete'

log_daily() {
    # Проверка аргументов
    if [ -z "${1:-}" ]; then
        echo "Usage: collect <server> [archive_prefix]"
        return 1
    fi

    local SERVER="$1"
    local ARCHIVE_PREFIX="${2:-$SERVER}"
    local LOCAL_DIR="$HOME/exp_kol"
    local TIMESTAMP
    local ARCHIVE_NAME
    local LOCAL_FILE

    mkdir -p "$LOCAL_DIR"

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ARCHIVE_NAME="${ARCHIVE_PREFIX}_${TIMESTAMP}.tar.gz"
    LOCAL_FILE="$LOCAL_DIR/$ARCHIVE_NAME"

    echo "=== Collecting from $SERVER ==="
    echo "Archive name: $ARCHIVE_NAME"

    # Отправляем скрипт на удалённый сервер и выполняем
    ssh "$SERVER" "bash -s -- '$ARCHIVE_NAME'" < ~/log_daily.sh

    echo "Downloading to: $LOCAL_FILE"
    scp "$SERVER:/tmp/$ARCHIVE_NAME" "$LOCAL_FILE"

    # Чистим временные файлы на сервере
    ssh "$SERVER" "rm -rf /tmp/${ARCHIVE_NAME%.tar.gz} ~/$ARCHIVE_NAME"

    echo "Done! Saved to: $LOCAL_FILE"
}

log_weekly() {
    # Проверка аргументов
    if [ -z "${1:-}" ]; then
        echo "Usage: collect <server> [archive_prefix]"
        return 1
    fi

    local SERVER="$1"
    local ARCHIVE_PREFIX="${2:-$SERVER}"
    local LOCAL_DIR="$HOME/exp_kol"
    local TIMESTAMP
    local ARCHIVE_NAME
    local LOCAL_FILE

    mkdir -p "$LOCAL_DIR"

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ARCHIVE_NAME="${ARCHIVE_PREFIX}_${TIMESTAMP}.tar.gz"
    LOCAL_FILE="$LOCAL_DIR/$ARCHIVE_NAME"

    echo "=== Collecting from $SERVER ==="
    echo "Archive name: $ARCHIVE_NAME"

    # Отправляем скрипт на удалённый сервер и выполняем
    ssh "$SERVER" "bash -s -- '$ARCHIVE_NAME'" < ~/log_weekly.sh

    echo "Downloading to: $LOCAL_FILE"
    scp "$SERVER:/tmp/$ARCHIVE_NAME" "$LOCAL_FILE"

    # Чистим временные файлы на сервере
    ssh "$SERVER" "rm -rf /tmp/${ARCHIVE_NAME%.tar.gz} ~/$ARCHIVE_NAME"

    echo "Done! Saved to: $LOCAL_FILE"
}

alias env_kolzovo="source venv/bin/activate"
alias cleanfile='f(){ iconv -f utf-8 -t utf-8 -c "$1" -o "$1.clean" && mv "$1.clean" "$1"; }; f' # очищает файл от скрытых символов
alias dd="docker-compose down -v"
alias du="docker-compose up -d"
alias dst="docker compose up --build"
alias scc="less ~/.ssh/config"
alias exp="cd ~/exp_kol/ && ls"
alias pjd="cd ~/dotspace_project ; ls -lah"
alias zrc="vim ~/.zshrc"
alias sc="vim ~/.ssh/config"
alias temp="~/work/project/temp"
alias res="source ~/.zshrc"
alias ll='ls -lah'
alias req="rm -rf ./roles ; ansible-galaxy install -r requirements.yml -f -v"
alias pj="cd ~/header_project && ls -lah"
alias ro="cd ~/header_project/roles/ && ls -lah"

function md() {
 mkdir -p "$1" 
 cd "$1"
}
alias help="less ~/helpfull"
alias dubl="grep -rH "" . | sort | uniq -d"
alias helpw="vim ~/main_account/helpfull"
alias main="cd ~/main_account/ && ls -lah"

function crsh() {
  local filename="${1}.sh"
  touch "$filename" 
  chmod 744 "$filename"
  echo '#!/bin/bash' > "$filename"
  vim "$filename"
}

function crpy() {
  local filename="${1}.py"
  touch "$filename"
  chmod 744 "$filename"
  echo '#!/usr/bin/env python3' > "$filename"
  vim "$filename"
}

function ii() {
    RED='\e[31m' # Красный цвет
    NC='\e[0m'   # Сброс цвета
    # время
    echo -e "${RED}Дата:${NC} $(date '+%d.%m.%Y %H:%M:%S')"
    echo -e "${RED}Время с последней перезагрузки:${NC} $(uptime -p)"

    # общая информация
    echo -e "${RED}$HOSTNAME ($(hostname -f))${NC}, ОС: $(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '\"' || lsb_release -d | cut -f2)"
    echo -e "${RED}Ядро:${NC} $(uname -r), ${RED}Архитектура:${NC} $(uname -m)"
    echo -e "${RED}Ядер:${NC} $(nproc), ${RED}Загрузка CPU:${NC} $(top -b -n1 | grep 'load average' | awk '{print $10, $11, $12}')"
    echo -e "${RED}Оперативная память:${NC} $(free -h | grep Mem | awk '{print $3 "/" $2}')"

    # топ-5 процессов
    echo -e "${RED}Топ-5 процессов по CPU/RAM:${NC}"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

    # диски
    echo -e "${RED}Диски:${NC} $(df -hT | grep -E '^/dev/')"

    echo -e "${RED}Типы дисков и свободное место:${NC}"
    for disk in /sys/block/sd*; do
        disk_name=$(basename "$disk")
        disk_type=$(cat "$disk/queue/rotational")
        type=$([ "$disk_type" -eq 1 ] && echo "HDD" || echo "SSD")
        free_space=$(df -h | grep "/dev/$disk_name" | awk '{print $4}')
        echo "$disk_name: $type, свободно: ${free_space:-неизвестно}"
    done

    # сеть
    echo -e "${RED}Шлюз:${NC} $(ip route | awk '/default/ { print $3 }')"
    echo -e "${RED}Сетевые интерфейсы:${NC} $(ip -br a | grep -v LOOPBACK)"
    echo -e "${RED}Открытые порты:${NC} $(ss -tuln)"
}

hg(){
if [ ! -z "$3" ];then
history | grep -i $1 | grep -i $2 | grep -i $3
elif [ ! -z "$2" ];then
history | grep -i $1 | grep -i $2
else
history | grep -i $1
fi
}

c() {
  if [[ $1 == *"git"* ]]; then
    if [[ -n "$2" ]]; then
      git clone "$1" "$2" && cd "$2"
    else
      git clone "$1"
    fi
  else
    ssh "$1"
  fi
}

#search_host() {
    # Функция для поиска машин, если передаётся один параметр,
    # и ОС, если имя ОС передаётся вторым параметром
    # Пример 1: search_host vostok
    # Пример 2: search_host run centos:7
    # Пример 2: search_host run bullseye
    # Если из под jump-а, то можно первый массив переделать на локальные адреса гипервизоров (кроме mari)
    # Для нормальной работы, в агенте д.б. ключ от используемого пользователя
#    LIST_IP=("95.213.175.58" "95.213.175.59" "95.213.175.60" "95.143.190.178" "84.38.185.166")
#    LIST_NAME=("anna" "leeloo" "daisy" "milena" "mari")
#    SSH_USER='mcart'
#    if [[ $2 ]]; then
#        for ((i=1; i<=${#LIST_IP[@]}; i++)); do
#            LIST_VM=$(ssh -o StrictHostKeyChecking=no $SSH_USER@$LIST_IP[$i] "sudo qm list | grep $1 | awk '{print \$2}' | xargs")
#            LIST_VM_ARRAY=($(echo $LIST_VM | tr " " "\n" | xargs))
#            RESULT=""
#            for ((j=1; j<=${#LIST_VM_ARRAY[@]}; j++)); do
#                if [[ ($(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -J $LIST_IP[$i] $SSH_USER@$LIST_VM_ARRAY[$j] "cat /etc/os-release | grep $2")) ]]; then
#                    RESULT+=($LIST_VM_ARRAY[$j])
#                fi
#            done
#            echo '----------------------------------------------------'
#            for ((k=2; k<=${#RESULT[@]}; k++)); do
#                echo 'на гипервизоре '$LIST_NAME[$i]' обнаружен '$2' на машине '$RESULT[$k]
#            done
#            echo '----------------------------------------------------'
#        done
#    else
#        for ((n=1; n<=${#LIST_IP[@]}; n++)); do
#            LIST_VM=$(ssh -o StrictHostKeyChecking=no $SSH_USER@$LIST_IP[$n] "hostname && sudo qm list | grep $1")
#            echo $LIST_VM
#            echo '----------------------------------------------------'
#        done
#    fi
#}
#sequer
alias passwdg="cat /dev/urandom |tr -dc A-Za-z0-9 | head -c $1"
function gpgres {
    echo "gpgconf --kill gpg-agent"
    echo "gpgconf --launch gpg-agent"
}
gpgres

# на случай если не правильно ввел пароль
function gpgrestart {
    echo "gpgconf --kill gpg-agent"
    echo "gpgconf --launch gpg-agent"
    gpg-connect-agent reloadagent /bye
    gpg-connect-agent killagent /bye
}

function rem {
    chmod 700 $1
    sudo chattr +i $1
}
alias yrem="sudo chattr -i $1"
function secretread() {
    local encrypt_file="$1"
    if [[ ! -f $encrypt_file ]]; then
        echo "Файл $encrypt_file не найден."
        return 1
    fi
    if [[ ${encrypt_file: -4} != ".gpg" ]]; then
        echo "Ошибка: файл должен иметь расширение .gpg"
        return 1
    fi
    local decrypted_file="${encrypt_file%.gpg}"
    gpg --quiet --batch --yes --decrypt --output "$decrypted_file" "$encrypt_file" || {
        echo "Не удалось расшифровать $encrypt_file."
        return 1
    }
    
    less "$decrypted_file"
    shred -u "$decrypted_file"
}

function secretwrite() {
    local encrypt_file="$1"
    local decrypted_file="${encrypt_file%.gpg}"
    gpg --quiet --batch --yes --decrypt --output "$decrypted_file" "$encrypt_file"
    vim "$decrypted_file"
    gpg --symmetric --batch --yes --output "$encrypt_file" "$decrypted_file"
    shred -u "$decrypted_file"
    chmod 700 "$encrypt_file"
}

function newsecret() {
    local file="$1"
    vim $1
    gpg --quiet --batch --yes --encrypt --recipient "gmomainsystem@gmail.com" --output $file.gpg $file
    shred -u $file
    chmod 700 $file.gpg
}

passwdc() {
    local search="$1"
    local encrypted_file="$HOME/.seq/passwd.gpg"
    local tmp_file

    # Создаём безопасный временный файл
    tmp_file=$(mktemp) || { echo "Не удалось создать временный файл"; return 1; }

    # Расшифровываем в временный файл
    gpg --quiet --batch --yes --decrypt --output "$tmp_file" "$encrypted_file" || {
        echo "Ошибка при расшифровке"
        shred -u "$tmp_file" 2>/dev/null
        return 1
    }

    # Ищем совпадения
    if [[ -n "$search" ]]; then
        grep -- "$search" "$tmp_file"
    else
        cat "$tmp_file"
    fi

    # Безопасно уничтожаем временный файл
    shred -u "$tmp_file" 2>/dev/null
}

passwdw() {
  local decrypted_file="$HOME/.seq/passwd"
  local encrypt_file="$HOME/.seq/passwd.gpg"
  local tmp_encrypt="$encrypt_file.tmp"
  local bak="$encrypt_file.bak"

  sudo chattr -i "$encrypt_file" 2>/dev/null || true

  # Расшифровать (если возможно) — если не получилось, выйти, не трогая ничего
  if ! gpg --quiet --batch --yes --decrypt --output "$decrypted_file" "$encrypt_file"; then
    echo "Ошибка: не удалось расшифровать $encrypt_file — отмена."
    return 1
  fi

  nano "$decrypted_file"

  # резервная копия старого зашифрованного файла
  if [ -f "$encrypt_file" ]; then
    cp --preserve=all "$encrypt_file" "$bak"
  fi

  # шифруем в временный файл; если неудача — не перезаписываем
  if ! gpg --symmetric --batch --yes --output "$tmp_encrypt" "$decrypted_file"; then
    echo "Ошибка шифрования — исходный файл сохранён, $tmp_encrypt не создан"
    shred -u "$decrypted_file"
    return 1
  fi

  mv -f "$tmp_encrypt" "$encrypt_file"
  chmod 700 "$encrypt_file"
  sudo chattr +i "$encrypt_file"
  shred -u "$decrypted_file"
  echo "OK"
}


#git
alias gitup="git fetch && git pull"
# checkout может из коммитов делать ветки git reflog выбераю нужный и дальше checkout HEAD@{N}
alias gbc="git checkout HEAD@{$1}"
alias gs="git status"

gbn() {
  branch_name=${1:-develop}
  git checkout -b "$branch_name"
}

gitdelb() {
if [ -z "$1" ]; then
  echo "Ошибка: не указано имя ветки для удаления."
  exit 1
fi
name_branch="origin/$1"
local_branch="$1"
if ! git show-ref --verify --quiet refs/heads/$local_branch; then
  echo "Ошибка: локальная ветка '$local_branch' не существует."
  exit 1
fi
echo "Переключаемся на ветку main..."
git checkout main
if [ $? -ne 0 ]; then
  echo "Ошибка: не удалось переключиться на ветку main."
  exit 1
fi
echo "Удаляем локальную ветку '$local_branch'..."
git branch -D $local_branch
if [ $? -ne 0 ]; then
  echo "Ошибка: не удалось удалить локальную ветку '$local_branch'."
  exit 1
fi
echo "Удаляем удаленную ветку '$name_branch'..."
git push origin --delete $local_branch
if [ $? -ne 0 ]; then
  echo "Ошибка: не удалось удалить удаленную ветку '$name_branch'."
  exit 1
fi
echo "Ветка '$name_branch' успешно удалена."
}
gitcheck() {
  local answer="full"
  find . -type d -name ".git" | sed 's/\/.git$//' | while IFS= read -r dir; do
    echo "Проверяем $dir..."
    cd "$dir" || { echo "Не удалось перейти в директорию $dir"; continue; }
    if [[ -n $(git status --porcelain) ]]; then
      echo "Незакоммиченные изменения найдены в $dir."
      git add . && git commit -m "$answer" && git push
      echo "Изменения закоммичены в $dir. с сообщением full. Не забывай комитить"
    else
      echo "Нет незакоммиченных изменений в $dir."
    fi
    cd - >/dev/null || exit
  done
}
#gitcheck

gitnew() {
    if [ -z "$1" ]; then
        echo "Usage: git_init_push <repository_url>"
        return 1
    fi

    git init
    touch .gitignore README.md
    git add .
    git commit -m "first commit"
    git branch -M main
    git remote add origin "$1"
    git push -u origin main
}

gitpush() {
    if [ -z "$1" ]; then
        echo "describe the changes"
        return 1
    fi
    git add . 
    git commit -m "$1"
    git push
}
gitupdate() {
  find . -type d -name ".git" | sed 's/\/.git$//' | while IFS= read -r dir; do
    echo "Проверяем $dir..."
    cd "$dir" || { echo "Не удалось перейти в директорию $dir"; continue; }
    if git fetch && git pull; then
      echo "Обновление $dir выполнено успешно."
    else
      echo "Ошибка обновления $dir."
    fi
    
    cd - >/dev/null || exit
  done
}
#gitupdate

gitinfo() {
  local logfile="~/gitinfo_$(date +%Y-%m-%d).log"
  find . -type d -name ".git" | sed 's/\/.git$//' | while IFS= read -r dir; do
    cd "$dir" || { echo "Не удалось перейти в директорию $dir"; continue; }
    git log --patch >> $logfile
    cd - >/dev/null || exit
  done
  less $logfile
  echo "Лог сохранен в $logfile"
}

alias groot="git rev-parse --git-common-dir" #определяет корневой репозиторий. если много worktree
alias gvn="git revert HEAD"
alias gv="git reset --soft HEAD~$1"
alias gvh="git reset --hard HEAD~$1"
alias gc="git add . && git commit -m $1"
alias grb="git rebase $1"

grname() {
  git branch -m $1 $2
  git push origin $2
  git push origin -d -f $1
}
gmerge() {
  git switch $2
  git merge -d $1
  git branch -D $1
}

alias gi="git for-each-ref --sort=authordate \
  --format='%(color:cyan)%(authordate:format:%m/%d/%Y %I:%M %p) %(align:25,left)%(refname:strip=3)%(end) %(authorname)' \
  refs/remotes"

alias gitpushforce="git push --force-with-lease" #откажется обновлять ветку, если ветка не указывает на одну и ту же ссылку или коммит
# git rev-parse --is-inside-git-dir - я нахожусь в .git ?
# git rev-parse --is-inside-work-tree - я нахожусь в подконтрольной ей директории

#ansible
alias ansvars="ansible-inventory --list --yaml | less"
alias req-dev='rm -rf ./roles ; ansible-galaxy install -r requirements-dev.yml -f -v'
mreq(){
  rm -rf ./roles
  cat requirements.yml | grep -v ^# | grep https://gitlab.mcart.ru > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    ansible-galaxy install -r requirements.yml -f -v
  else
    cat requirements.yml | sed 's/https:\/\/gitlab.mcart.ru\//git@gitlab.mcart.ru:/g' > /tmp/req.yml
    ansible-galaxy install -r /tmp/req.yml -f -v
    rm -f /tmp/req.yml
  fi
}

#yc
alias sqlstart="yc managed-postgresql cluster start $1 --async"
alias sqlstop="yc managed-postgresql cluster stop $1 --async"
alias vmyc="ssh -l yc-user $1"
alias vminfo="yc compute instance get --name $1"
alias vmall="yc compute instance list"

#  IMAGE_ID=fd8pkn4ct4ofk1o43m2b"  для дома
vmycr() {
  IMAGE_ID="fd8kucl0qo9ae6pjqadu" # centos9 work
  INSTANCE_NAME="$1"        
  ZONE="ru-central1-a"      

  yc compute instance create \
    --name $INSTANCE_NAME \
    --zone $ZONE \
    --create-disk image-id=fd8kucl0qo9ae6pjqadu,size=20GB,type=network-hdd \
    --hostname $INSTANCE_NAME \
    --memory 4GB \
    --cores 2 \
    --core-fraction 20 \
    --network-interface subnet-name=net-2-ru-central1-a,nat-ip-version=ipv4 \
   # --service-account-id ajegk5u8vber4anhht1v \
    --service-account-id ajeha6u0luu5hhpe9vnu \
    --preemptible \
    --ssh-key ~/.ssh/work/mcart_deploy \
# --ssh-key /home/$USER/.ssh/life/life.pub \
    --async \
    --force
}

vmycstop() {
  local INSTANCE_NAME=$1
  if [[ -z $INSTANCE_NAME ]]; then
    echo "Укажите имя ВМ для остановки. Функция для yc"
    return 1
  fi

  yc compute instance stop --name "$INSTANCE_NAME" --async && \
  echo "ВМ '$INSTANCE_NAME' остановлена." || \
  echo "Ошибка: не удалось остановить ВМ '$INSTANCE_NAME'."
}

vmycdel() {
  local INSTANCE_NAME=$1
  if [[ -z $INSTANCE_NAME ]]; then
    echo "Укажите имя ВМ для удаления. Функция для yc"
    return 1
  fi

  yc compute instance delete --name "$INSTANCE_NAME" --async && \
  echo "ВМ '$INSTANCE_NAME' удалена." || \
  echo "Ошибка: не удалось удалить ВМ '$INSTANCE_NAME'."
}


sqlcreate() {
    # Переменные для настроек
    local cluster_name="study"
    local backup_id="c9qp0gj6k28snf6eqve1:c9qlh1cgs35qqd7q6vak"
    local zone_id="ru-central1-a"
    local subnet_id="e9bju8hvmvomjsvel06v"
    local network_name="default"
    local disk_type="network-hdd"
    local disk_size=10
    local labels="goncharov=study"

    echo "процесс займет около 12 минут"

    # Восстановление кластера
    yc managed-postgresql cluster restore \
        --name "$cluster_name" \
        --backup-id "$backup_id" \
        --host "zone-id=$zone_id,subnet-id=$subnet_id" \
        --network-name "$network_name" \
        --disk-type "$disk_type" \
        --disk-size "$disk_size" \
        --labels "$labels" \

    if [ $? -eq 0 ]; then
        echo "Кластер восстановлен успешно. Пытаюсь включить WebSQL."
        # Обновление кластера для включения WebSQL
        yc managed-postgresql cluster update \
            --name "$cluster_name" \
            --websql-access
    else
        echo "Ошибка при восстановлении кластера. WebSQL не будет включён."
        return 1
    fi

    echo "Операция завершена."
}

sqldel() {
    local cluster_name=$1
    yc managed-postgresql cluster delete \
    --name "$cluster_name"
    --async
}
