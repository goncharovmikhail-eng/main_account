#!/bin/bash

curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
sudo apt install -y bash-completion

echo "# The next line updates PATH for CLI." >> ~/.zshrc
echo "export PATH=\"/home/goncharov/yandex-cloud/bin:\$PATH\"" >> ~/.zshrc
echo "if [ -f '/home/goncharov/yandex-cloud/path.bash.inc' ]; then source '/home/goncharov/yandex-cloud/path.bash.inc'; fi" >> ~/.zshrc
echo "# The next line enables shell command completion for yc." >> ~/.zshrc
echo "if [ -f '/home/goncharov/yandex-cloud/completion.bash.inc' ]; then source '/home/goncharov/yandex-cloud/completion.bash.inc'; fi" >> ~/.zshrc

echo "Installation YC complete. Please reboot your terminal, then run 'yc init' for personal setup or use alias 'workcloud' if configured."

