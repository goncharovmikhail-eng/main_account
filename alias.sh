function gpgrest {
    echo "gpgconf --kill gpg-agent"
    echo "gpgconf --launch gpg-agent"
}
gpgrest
function nrem {
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
    nano "$decrypted_file"
    gpg --symmetric --batch --yes --output "$encrypt_file" "$decrypted_file"
    shred -u "$decrypted_file"
    chmod 700 "$encrypt_file"
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
gitcheck

con() {
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

alias md='mkdir -p'
alias vmyc="ssh -l yc-user $1"
alias vminfo="yc compute instance get --name $1"
alias vmall="yc compute instance list"
vmycr() {
  IMAGE_ID="fd8pkn4ct4ofk1o43m2b" 
  INSTANCE_NAME="$1"        
  ZONE="ru-central1-b"      

  yc compute instance create \
    --name $INSTANCE_NAME \
    --zone $ZONE \
    --create-disk image-id=$IMAGE_ID,size=20GB,type=network-hdd \
    --hostname $INSTANCE_NAME \
    --memory 4GB \
    --cores 2 \
    --core-fraction 20 \
    --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
    --service-account-id ajegk5u8vber4anhht1v \
    --preemptible \
    --ssh-key /home/$USER/.ssh/life/life.pub \
    --async
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

alias ltasks="nano /home/goncharov/life/main_account/ltasks"
alias wtasks="nano /home/goncharov/work/wtasks"
function newsecret() {
    local file="$1"
    nano $1
    gpg --quiet --batch --yes --encrypt --recipient "gmomainsystem@gmail.com" --output $file.gpg $file
    shred -u $file
    chmod 700 $file.gpg
}
function passwdc() {
    local decrypted_file="/home/$USER/passwd"
    gpg --quiet --batch --yes --decrypt --output $decrypted_file /home/$USER/passwd.gpg
    cat $decrypted_file | grep $1
    shred -u $decrypted_file
}
function passwdw() {
    local decrypted_file="/home/$USER/passwd"
    local encrypt_file="/home/$USER/passwd.gpg"
    sudo chattr -i $encrypt_file
    gpg --quiet --batch --yes --decrypt --output $decrypted_file $encrypt_file
    nano $decrypted_file
    gpg --symmetric --batch --yes --output $encrypt_file $decrypted_file
    shred -u $decrypted_file
    chmod 700 $encrypt_file
    sudo chattr +i $encrypt_file
}
function passwdvars() {
    local decrypted_file="/home/$USER/passwd_variable.sh"
    local encrypt_file="/home/$USER/passwd_variable.sh.gpg"
    sudo chattr -i $encrypt_file
    gpg --quiet --batch --yes --decrypt --output $decrypted_file $encrypt_file
    nano $decrypted_file
    gpg --symmetric --batch --yes --output $encrypt_file $decrypted_file
    shred -u $decrypted_file
    chmod 700 $encrypt_file
    sudo chattr +i $encrypt_file
}

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
alias req-dev='rm -rf ./roles ; ansible-galaxy install -r requirements-dev.yml -f -v'
function ii() {
        echo -e "\nВы находитесь на ${RED}$HOSTNAME ($(hostname -f))"
        echo -e "\nДополнительная информация:$NC" ; uname -a
        echo -e "\n${RED}В системе работают пользователи:$NC" ; w -h
        echo -e "\n${RED}Дата:$NC" ; date '+%d.%m.%Y %H:%M:%S'
        echo -e "\n${RED}Время, прошедшее с момента последней перезагрузки:$NC" ; uptime| sed 's/^[ \t]*//;s/[ \t]*$//'
        echo -e "\n${RED}Память:$NC" ; free
        GW=$(ip route | awk '/default/ { print $3 }')
        echo -e "\n${RED}Основной шлюз:$NC" ; echo ${GW}
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
alias life="cd ~/life && ls -lah"
alias work="cd ~/work && ls -lah"
alias ll='ls -lah'
alias req="rm -rf ./roles ; ansible-galaxy install -r requirements.yml -f -v"
alias pj="cd /home/$USER/mcart/project/ && ls -lah"
alias ro="cd /home/$USER/mcart/roles/ && ls -lah"
alias gs="git status"
#work
alias daisy='ssh mcart@95.213.175.60'
alias workcloud="yc init --federation-id=bpf7ckgu1acbcas8na7r"
alias tasksc="cat ~/mcart/tasks"
alias tasksw="nano ~/mcart/tasks"
alias aliasw="nano ~/life/main_account/alias.sh"
alias aliasc="cat ~/life/main_account/alias.sh | grep $1"
#alias passwdc="cat ~/passwd | grep $1"
#alias passwdw="nano ~/passwd"
alias infrawork="cd /home/goncharov/mcart/mcart-infrastructure"
alias jump="ssh -A -J m.goncharov@95.213.175.59 m.goncharov@10.64.1.230"
alias mcart="cd /home/goncharov/mcart/"
alias sqlstart="yc managed-postgresql cluster start $1 --async"
alias sqlstop="yc managed-postgresql cluster stop $1 --async"

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
