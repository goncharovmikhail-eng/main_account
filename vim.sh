#!/bin/bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

pip install jedi --break-system-packages

echo "call plug#begin('~/.vim/plugged')" > ~/.vimrc
echo "Plug 'jiangmiao/auto-pairs'" >> ~/.vimrc
echo "Plug 'davidhalter/jedi-vim'"  >> ~/.vimrc
echo "Plug 'dense-analysis/ale'"  >> ~/.vimrc
echo "Plug 'vim-scripts/bash-support.vim'"  >> ~/.vimrc
echo "call plug#end()"  >> ~/.vimrc
echo "syntax on"  >> ~/.vimrc
echo "filetype plugin indent on"  >> ~/.vimrc
echo "set number"  >> ~/.vimrc
echo "set tabstop=4"  >> ~/.vimrc
echo "set shiftwidth=4"  >> ~/.vimrc
echo "set expandtab"  >> ~/.vimrc
