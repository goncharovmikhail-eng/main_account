#general
alias md='mkdir -p'
alias ansvars="ansible-inventory --list --yaml | less"
alias help="less /home/$USER/helpfull"
alias helpw="nano /home/$USER/helpfull"

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

function nrem {
    chmod 700 $1
    sudo chattr +i $1
}
alias yrem="sudo chattr -i $1"
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

#proxmox
search_host() {
    # Функция для поиска машин, если передаётся один параметр,
    # и ОС, если имя ОС передаётся вторым параметром
    # Пример 1: search_host vostok
    # Пример 2: search_host run centos:7
    # Пример 2: search_host run bullseye
    # Если из под jump-а, то можно первый массив переделать на локальные адреса гипервизоров (кроме mari)
    # Для нормальной работы, в агенте д.б. ключ от используемого пользователя
    LIST_IP=("95.213.175.58" "95.213.175.59" "95.213.175.60" "95.143.190.178" "84.38.185.166")
    LIST_NAME=("anna" "leeloo" "daisy" "milena" "mari")
    SSH_USER='mcart'
    if [[ $2 ]]; then
        for ((i=1; i<=${#LIST_IP[@]}; i++)); do
            LIST_VM=$(ssh -o StrictHostKeyChecking=no $SSH_USER@$LIST_IP[$i] "sudo qm list | grep $1 | awk '{print \$2}' | xargs")
            LIST_VM_ARRAY=($(echo $LIST_VM | tr " " "\n" | xargs))
            RESULT=""
            for ((j=1; j<=${#LIST_VM_ARRAY[@]}; j++)); do
                if [[ ($(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -J $LIST_IP[$i] $SSH_USER@$LIST_VM_ARRAY[$j] "cat /etc/os-release | grep $2")) ]]; then
                    RESULT+=($LIST_VM_ARRAY[$j])
                fi
            done
            echo '----------------------------------------------------'
            for ((k=2; k<=${#RESULT[@]}; k++)); do
                echo 'на гипервизоре '$LIST_NAME[$i]' обнаружен '$2' на машине '$RESULT[$k]
            done
            echo '----------------------------------------------------'
        done
    else
        for ((n=1; n<=${#LIST_IP[@]}; n++)); do
            LIST_VM=$(ssh -o StrictHostKeyChecking=no $SSH_USER@$LIST_IP[$n] "hostname && sudo qm list | grep $1")
            echo $LIST_VM
            echo '----------------------------------------------------'
        done
    fi
}

#YC
alias vminfo="yc compute instance get --name $1"
alias vmall="yc compute instance list"
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

sqldel() {
    local cluster_name=$1
    yc managed-postgresql cluster delete \
    --name "$cluster_name"
    --async
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

#git
alias gitupdateonce="git fetch && git pull"
gitcheck() {
  local answer="autocommit"
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
#gitcheck # Раскомментить при необходимости #push при создании новой сессии
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
# Раскомментить при необходимости  #gitupdate #обновляет локальные репозитории при создании новой сессии

gitpush() {
    if [ -z "$1" ]; then
        echo "describe the changes"
        return 1
    fi
    git add .
    git commit -m "$1"
    git push
}

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
