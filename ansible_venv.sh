#!/bin/bash - 
#===============================================================================
#
#          FILE: ansible_venv.sh
# 
#         USAGE: ./ansible_venv.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Goncharov M. (), 
#  ORGANIZATION: 
#       CREATED: 08/13/2025 17:04
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

sudo apt update
sudo apt install python3-venv -y
python3 -m venv ~/ansible-2.9-env
ansible --version
echo "source ~/ansible-2.9-env/bin/activate" >> /home/$USER/.zshrc
