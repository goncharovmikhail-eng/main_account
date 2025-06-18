echo '# запуск ssh-agent и добавление ключей' >> ~/.zshrc
echo 'eval $(ssh-agent -s)' >> ~/.zshrc
echo 'ssh-add ~/.ssh/goncharov_work' >> ~/.zshrc
echo 'ssh-add ~/.ssh/my' >> ~/.zshrc
echo 'ssh-add ~/.ssh/test' >> ~/.zshrc
echo 'source /home/$USER/main_account/alias.sh' >> ~/.zshrc
