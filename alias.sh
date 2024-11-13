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
alias daisy='ssh 95.213.175.60'
