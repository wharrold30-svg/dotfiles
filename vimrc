""=============================================================================
"" 1. CORE VIM SETTINGS & INITIALIZATION
""=============================================================================
let mapleader = ","

set nocompatible              " be iMproved, required
filetype off                  " required

set encoding=utf-8
set mouse=a
set number
"set cursorline
set guioptions=
syntax on

set ignorecase
set smartcase
set backspace=indent,eol,start
set tags=./tags,tags;$HOME

""=============================================================================
"" 2. VUNDLE PLUGIN MANAGER CONFIGURATION
""=============================================================================
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Inside your call vundle#begin() block:
Plugin 'Valloric/YouCompleteMe'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'google/vim-maktaba'
Plugin 'google/vim-codefmt'
Plugin 'google/vim-glaive'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'Raimondi/delimitMate'
Plugin 'morhetz/gruvbox'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'majutsushi/tagbar'
Plugin 'Yggdroot/indentLine'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'preservim/vimux'
Plugin 'tpope/vim-fugitive'
Plugin 'rhysd/vim-clang-format'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Glaive Activation
call glaive#Install()        " enable this line after the installation of glaive

""=============================================================================
"" 3. KEY MAPPINGS (GLOBAL & WINDOWS)
""=============================================================================
" Press 'q' in normal mode to safely close everything
nnoremap q :qa<CR>
nnoremap s :w<CR>

" Resize Vim windows using Alt + Arrow keys
nnoremap <M-Up> :resize +2<CR>
nnoremap <M-Down> :resize -2<CR>
nnoremap <M-Left> :vertical resize +2<CR>
nnoremap <M-Right> :vertical resize -2<CR>

""=============================================================================
"" 4. THEME & APPEARANCE CONFIGURATION
""=============================================================================
set termguicolors
set t_Co=256
set background=dark
colorscheme desert

" let g:gruvbox_contrast_dark = 'soft'

""=============================================================================
"" 5. INDENTATION & TABS (GLOBAL & LANGUAGE SPECIFIC)
""=============================================================================
" indent for global
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent

" indent for special file
autocmd FileType c,cpp setlocal expandtab shiftwidth=2 softtabstop=2 cindent
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4 autoindent

""=============================================================================
"" 6. PLUGIN SETTINGS & EXTRA MAPPINGS
""=============================================================================

""--- YouCompleteMe (YCM) ---
let g:ycm_confirm_extra_conf = 0
" setup for ycm
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py'
let g:ycm_python_binary_path = 'python'
let g:ycm_complete_in_comments = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_semantic_triggers =  {
  \ 'c' : ['re!\w{2}'],
  \ 'cpp' : ['re!\w{2}'],
  \ 'python' : ['re!\w{2}'],
  \ }

""--- Syntastic ---
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_c_checkers = ['gcc']
let g:syntastic_cpp_checkers = ['gcc']

""--- Google Codefmt & Autoformat ---
augroup autoformat_settings
  autocmd FileType c,cpp,proto,javascript AutoFormatBuffer clang-format
  autocmd FileType python AutoFormatBuffer yapf
augroup END
" use google style for clang-format
Glaive codefmt clang_format_style='google'

""--- Clang-Format ---
" Automatically format C/C++ files on save
let g:clang_format#auto_format = 1
" Map \cf to manually format code in Normal or Visual mode
autocmd FileType c,cpp,objc,java nnoremap <buffer><Leader>cf :ClangFormat<CR>
autocmd FileType c,cpp,objc,java vnoremap <buffer><Leader>cf :ClangFormat<CR>

""--- C++ Syntax Highlighting ---
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_from_base_highlight = 1
let g:cpp_concepts_highlight = 1

""--- NERDTree ---
let NERDTreeShowHidden=1
nnoremap <C-d> :NERDTreeToggle<CR>
"map <silent> <F5> : NERDTreeToggle<CR>

" open NERDTree automatically when vim starts up on opening a directory
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Automatically quit Vim if NERDTree is the only window left open
autocmd BufEnter * if tabpagenr("$") == 1 && winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree() | qa | endif

""--- CtrlP ---
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

""--- Tagbar ---
nnoremap <Leader>8 :TagbarToggle<CR>

""--- IndentLine ---
let g:indentLine_char = '│'

""=============================================================================
"" 7. TMUX INTEGRATION & EXTERNAL TOOLS
""=============================================================================
"source ~/cscope_maps.vim

" Automatically create a vertical tmux pane when a file is opened
"autocmd BufReadPost,BufNewFile * silent! !tmux split-window -h"

let g:spawned_tmux_pane = ""

function! OpenTmuxPane()
  if g:spawned_tmux_pane == ""
    " Create one clean side-pane taking up 25% of the screen width
    let l:pane_id = system("tmux split-window -h -d -P -F '#{pane_id}' -p 25")
    let g:spawned_tmux_pane = substitute(l:pane_id, '\n$', '', '')
  endif
endfunction

function! CloseTmuxPane()
  if g:spawned_tmux_pane != ""
    call system("tmux kill-pane -t " . g:spawned_tmux_pane)
    let g:spawned_tmux_pane = ""
  endif
endfunction

" Automation hooks
autocmd VimEnter * call OpenTmuxPane()
autocmd VimLeave * call CloseTmuxPane()

""=============================================================================
"" 8. CUSTOM C++ SYNTAX COLORING GROUPS
""=============================================================================
" Link standard containers & classes to Vim's built-in Type color (usually blue/green)
highlight link cCustomClass Type
highlight link cppStructure Type
highlight link cppType Type

" Link standard namespaces & scopes (like std::) to Vim's Statement color (usually yellow/red)
highlight link cCustomScope Statement

" Optional: Link custom member variables and templates to Identifier (usually cyan)
highlight link cCustomMemVar Identifier
highlight link AngleBracketContents Identifier

