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
alias ll='ls -lah'
alias req="rm -rf ./roles ; ansible-galaxy install -r requirements.yml -f -v"
alias pj="cd /home/$USER/mcart/project/ && ls -lah"
alias ro="cd /home/$USER/mcart/roles/ && ls -lah"
#work
alias daisy='ssh mcart@95.213.175.60'
alias workcloud="yc init --federation-id=bpf7ckgu1acbcas8na7r"
alias tasksc="cat ~/mcart/tasks"
alias tasksw="nano ~/mcart/tasks"
alias aliasw="nano ~/life/main_account/alias.sh"
alias aliasc="cat ~/life/main_account/alias.sh | grep $1"
alias passwdc="cat ~/passwd | grep $1"
alias passwdw="nano ~/passwd"
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
