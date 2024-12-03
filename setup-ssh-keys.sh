echo '# запуск ssh-agent и добавление ключей' >> ~/.zshrc
echo 'eval $(ssh-agent -s)' >> ~/.zshrc
echo 'ssh-add ~/.ssh/work/mcart_deploy' >> ~/.zshrc
echo 'ssh-add ~/.ssh/work/goncharov_work' >> ~/.zshrc
echo 'ssh-add ~/.ssh/life/life' >> ~/.zshrc
echo 'ssh-add ~/.ssh/study/study' >> ~/.zshrc
echo 'source /home/$USER/life/main_account/alias.sh' >> ~/.zshrc
