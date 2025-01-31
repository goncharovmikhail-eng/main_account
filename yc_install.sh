#!/bin/bash

curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
sudo apt install -y bash-completion

echo "# The next line updates PATH for CLI." >> ~/.zshrc
echo "export PATH=\"/home/$USER/yandex-cloud/bin:\$PATH\"" >> ~/.zshrc
echo "if [ -f '/home/$USER/yandex-cloud/path.bash.inc' ]; then source '/home/$USER/yandex-cloud/path.bash.inc'; fi" >> ~/.zshrc
echo "# The next line enables shell command completion for yc." >> ~/.zshrc
echo "if [ -f '/home/$USER/yandex-cloud/completion.bash.inc' ]; then source '/home/$USER/yandex-cloud/completion.bash.inc'; fi" >> ~/.zshrc

echo "Installation YC complete. Please reboot your terminal, then first run 'yc init' for personal setup,then use alias 'workcloud' if configured."

