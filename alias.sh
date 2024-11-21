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
alias sqlstart="yc managed-postgresql cluster start c9qp0gj6k28snf6eqve1 --async"
alias sqlstop="yc managed-postgresql cluster stop c9qp0gj6k28snf6eqve1 --async"
