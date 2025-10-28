#!/bin/bash

# Установка vim-plug (менеджер плагинов)
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Python-зависимости
pip install jedi flake8 yamllint --break-system-packages

# Установка зависимостей (включая линтеры и ripgrep)
if command -v apt &>/dev/null; then
    sudo apt update
    sudo apt -y install shellcheck ripgrep vim
elif command -v dnf &>/dev/null; then
    sudo dnf install -y ShellCheck ripgrep vim
fi
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshrc
nvm install --lts
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm --version    
nvm install --lts 
node -v          

# Создание ~/.vimrc с полной конфигурацией
cat << 'EOF' > ~/.vimrc
call plug#begin('~/.vim/plugged')

" Автозакрытие скобок
Plug 'jiangmiao/auto-pairs'

" Python автокомплит (jedi)
Plug 'davidhalter/jedi-vim'

" Линтер и fixer
Plug 'dense-analysis/ale'

" Поддержка bash
Plug 'vim-scripts/bash-support.vim'

" Файловое дерево
Plug 'preservim/nerdtree'

" Быстрый поиск
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdcommenter'
" Переключение между исходником и тестом
Plug 'tpope/vim-projectionist'

" YAML
Plug 'stephpy/vim-yaml'

" LSP и автокомплит
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" --- Общие настройки ---
syntax on
filetype plugin indent on
set mouse=a
set number
set tabstop=4
set shiftwidth=4
set expandtab
set foldcolumn=2
set colorcolumn=80
highlight ColorColumn ctermbg=green guibg=lightgrey
colorscheme desert

" --- YAML отступы ---
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" --- Клавиши ---
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-p> :Files<CR>
nnoremap <leader>a :A<CR>

" --- FZF: ripgrep поиск ---
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob "!.git/*"'

" --- ALE: линтеры ---
let g:ale_fix_on_save = 1
let g:ale_linters = {
\   'python': ['flake8'],
\   'yaml': ['yamllint'],
\   'sh': ['shellcheck'],
\}

" --- COC: автокомплит и YAML ---
let g:coc_global_extensions = ['coc-yaml']

" --- Projectionist: привязка src <-> test ---
let g:projectionist_heuristics = {
\   "*/src/*.py": {
\     "src/*.py": {
\       "alternate": "tests/test_{}.py",
\       "type": "source"
\     },
\     "tests/test_{}.py": {
\       "alternate": "src/{}.py",
\       "type": "test"
\     }
\   }
\}
EOF

# Установка всех плагинов
vim +PlugInstall +qall

# Инструкция по установке coc-расширений
echo "Для завершения настройки coc.nvim, открой Vim и выполни:"
echo ":CocInstall coc-yaml"

