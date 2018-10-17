if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible	" Use Vim defaults (much better!)
set bs=indent,eol,start		" allow backspacing over everything in insert mode
"set ai			" always set autoindenting on
"set backup		" keep a backup file
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			" than 50 lines of registers
set history=2000		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
" 总是显示状态栏
set laststatus=2
" 显示光标当前位置
set ruler
" 开启行号显示
set number
" 高亮显示当前行/列
set cursorline
" set cursorcolumn
" 高亮显示搜索结果
set hlsearch
" 设置tab键为4  设置自动tab对齐
"set tabstop=4
"set autoindent
"set smartindent
"set expandtab
"set shiftwidth=4

"  设置引号,大括号自动的生成匹配
"inoremap " ""<ESC>i
"inoremap ' ''<ESC>i
"inoremap ( ()<ESC>i
"inoremap [ []<ESC>i
"inoremap { {}<ESC>i

" Only do this part when compiled with support for autocommands
if has("autocmd")
  augroup redhat
  autocmd!
  " In text files, always limit the width of text to 78 characters
  " autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
  " don't write swapfile on most commonly used directories for NFS mounts or USB sticks
  autocmd BufNewFile,BufReadPre /media/*,/run/media/*,/mnt/* set directory=~/tmp,/var/tmp,/tmp
  " start with spec file template
  autocmd BufNewFile *.spec 0r /usr/share/vim/vimfiles/template.spec
  augroup END
endif

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add $PWD/cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
" 设置高亮显示
  syntax on
  set hlsearch
endif

filetype plugin on

if &term=="xterm"
     set t_Co=8
     set t_Sb=[4%dm
     set t_Sf=[3%dm
endif
" 对文件类型的判断
filetype on
filetype indent on
"  ---------------------插件设置-------------------------------------------
" 添加bundel的支持
filetype off
syntax on
set rtp+=~/.vim/bundle/vundle/
call vundle#begin()
" 加载插件
 Plugin 'VundleVim/Vundle.vim'
 " 文档资源管理器  文件的下导航
 Plugin 'Lokaltog/vim-powerline'
 " 文档树
 Plugin 'scrooloose/nerdtree'
 " color文件
 Plugin 'vim-airline/vim-airline'
 Plugin 'vim-airline/vim-airline-themes'
 Plugin 'michaelHL/awesome-vim-colorschemes'
 "Plugin 'Tagbar'
 "标签树和tag自动增加
 Plugin 'Tabular'
 Plugin 'majutsushi/tagbar'
 "tab赋予魔力
 Plugin 'SuperTab'
 "代码的提示错误
 Plugin 'Syntastic'
 "自动括号补全
 Plugin 'jiangmiao/auto-pairs'
 "注释多语言的快捷键 
 "n\cc : 为光标以下 n 行添加注释
 "n\cu : 为光标以下 n 行取消注释
 "n\cm : 为光标以下 n 行添加块注释
 Plugin 'scrooloose/nerdcommenter'
 "Plugin 'MiniBufferExplorer'
 "撤销树
 Plugin 'mbbill/undotree'
 call vundle#end()
 filetype plugin indent on     " required
 "SuperTab快捷键
 "0 - 不记录上次的补全方式
 "1 - 记住上次的补全方式,直到用其他的补全命令改变它
 "2 - 记住上次的补全方式,直到按ESC退出插入模式为止
 let g:SuperTabRetainCompletionType=2
 " 插件快捷键
 " syntastic快捷键
 let g:syntastic_always_populate_loc_list = 1
 let g:syntastic_check_on_open = 1
 let g:syntastic_auto_jump = 1
 nmap <F6> :Tagbar <CR>
 nmap <F5> :NERDTreeToggle<cr>
 nmap <F4> :wq<cr>
 nmap <F1> :set nu<cr>
 nmap <F2> :set nonu<cr>
 nmap <F4> :wq<cr>
 nnoremap <F3> :UndotreeToggle<cr>
 map <F7> <Esc>:!ctags -R <CR><CR>
" --------------------- 
"  作者：qqstring 
"  来源：CSDN 
"  原文：https://blog.csdn.net/qqstring/article/details/81511174?utm_source=copy 
"    ----------------------插件设置关闭------------------------------------------
" Don't wake up system with blinking cursor:
" http://www.linuxpowertop.org/known.php
let &guicursor = &guicursor . ",a:blinkon0"


"             ---------------------------颜色主题设置------------------------------------- 
set background=dark
"colorscheme solarized
"colorscheme molokai
"colorscheme one
"colorscheme phd
colorscheme atom
"colorscheme molokai
"            ------------------------------字体设置 #12是字体大小------------------------- 
"          set guifont=Source\ Code\ Pro\ 15
"            ---------------------------颜色主题设置关闭---------------------------------
"
