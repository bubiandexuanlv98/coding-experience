set nocompatible              " be iMproved, required
filetype off                  " required

silent! py3 pass

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Tree plugins
Plugin 'scrooloose/nerdtree'         " A tree explorer plugin
Plugin 'jistr/vim-nerdtree-tabs'     " NERDTree and tabs together
Plugin 'Xuyuanp/nerdtree-git-plugin' " NERDTree showing git status
Plugin 'mbbill/undotree'             " The undo history visualizer for VIM

" Coding support
Plugin 'neoclide/coc.nvim'
Plugin 'neoclide/coc-json'
Plugin 'neoclide/coc-tsserver'
Plugin 'neoclide/coc-git'
Plugin 'neoclide/coc-html'
" Plugin 'neoclide/coc-prettier'
Plugin 'neoclide/coc-highlight'
Plugin 'neoclide/coc-yaml'
Plugin 'neoclide/coc-yank'

Plugin 'josa42/coc-go'
Plugin 'fannheyward/coc-markdownlint'
" Plugin 'fannheyward/coc-pyright' " already have ale pyright

Plugin 'weirongxu/coc-calc'
Plugin 'josa42/coc-sh'
Plugin 'fannheyward/coc-sql'
Plugin 'kkiyama117/coc-toml'
Plugin 'iamcco/coc-vimlsp'
Plugin 'fannheyward/coc-xml'

Plugin 'Valloric/YouCompleteMe'       " A code-completion engine
Plugin 'dense-analysis/ale'           " Check syntax in Vim asynchronously and fix files
Plugin 'SirVer/ultisnips'             " The ultimate snippet solution
Plugin 'ludovicchabant/vim-gutentags' " Manages your tag files
Plugin 'tpope/vim-commentary'         " Comment stuff out
Plugin 'puremourning/vimspector'      " A multi language graphical debugger
Plugin 'luochen1990/rainbow'          " Show diff level of parentheses in diff color

" Git support
Plugin 'tpope/vim-fugitive'       " A Git wrapper so awesome
Plugin 'airblade/vim-gitgutter'   " Shows a git diff in the gutter
Plugin 'junegunn/gv.vim'          " A git commit browser
Plugin 'jreybert/vimagit'         " Visualize all diffs in your git repository
Plugin 'AndrewRadev/linediff.vim' " Perform diffs on blocks of code

" Search/Substitute tools
Plugin 'ctrlpvim/ctrlp.vim' " Full path fuzzy file, buffer, mru, tag, ... finder
Plugin 'mileszs/ack.vim'    " Your favorite search tool
Plugin 'tpope/vim-abolish'  " Easily search for, substitute, and abbreviate multiple variants of a word

" UI enhancement
Plugin 'vim-airline/vim-airline'   " Lean & mean status/tabline for vim that's light as air
Plugin 'majutsushi/tagbar'         " Displays tags in a window, ordered by scope
Plugin 'mhinz/vim-startify'        " The fancy start screen for Vim
Plugin 'junegunn/vim-peekaboo'     " See the contents of the registers
Plugin 'ryanoasis/vim-devicons'    " Add filetype icons

Plugin 'tpope/vim-surround'        " Quoting/parenthesizing made simple
Plugin 'tpope/vim-dispatch'        " Asynchronous build and test dispatcher
Plugin 'tpope/vim-unimpaired'      " Pairs of handy bracket mappings
Plugin 'tpope/vim-repeat'          " Enable repeating supported plugin maps with .
Plugin 'AndrewRadev/splitjoin.vim' " Simplify the transition between multiline and single-line code
Plugin 'godlygeek/tabular'         " Text filtering and alignment
Plugin 'easymotion/vim-easymotion' " Vim motions on speed
Plugin 'vim-test/vim-test'         " A Vim wrapper for running tests on different granularities.
Plugin 'mattn/webapi-vim'

" Programming language specific plugins
" Golang
Plugin 'fatih/vim-go'         " Go development plugin
" Python
Plugin 'davidhalter/jedi-vim' " Awesome Python autocompletion
Plugin 'Vimjas/vim-python-pep8-indent'

" Markdown Support
Plugin 'plasticboy/vim-markdown'                                          " Syntax highlighting, matching rules and mappings for the original Markdown and extensions
Plugin 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' } " Preview markdown on your modern browser with synchronised scrolling and flexible configuration

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
filetype plugin on
syntax on
set number
set tabstop=2
set shiftwidth=2
set expandtab
set nowrap
set updatetime=1000
set smartindent
set autoindent
set incsearch " Start searching before pressing enter.
" set encoding=UTF-8
" set foldmethod=syntax

" Always show at least one line above/below the cursor.
if !&scrolloff
  set scrolloff=1
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline

" Enable scrolling with the scroll wheel
set mouse=a
" Toggles folds with mouse click
" set foldcolumn=1
" Toggles folds with mouse triple click
noremap <3-LeftMouse> zA
nmap <C-LeftMouse> <LeftMouse>gd

" Plugin 'scrooloose/nerdtree'
if &diff
  let loaded_nerd_tree=1
else
  let g:nerdtree_tabs_open_on_console_startup=1
  " move the cursor to the file editing area
  autocmd VimEnter * NERDTree | wincmd p
endif
" use <Tab> to quick switch between NERDTree and file
noremap <Tab> <C-W><C-W>

" Plugin 'Xuyuanp/nerdtree-git-plugin'
let g:NERDTreeGitStatusUseNerdFonts = 1
" let g:NERDTreeGitStatusConcealBrackets = 1

" Plugin 'fatih/vim-go'
" If gopls stucks, try the following commands first
" $> go mod download all
" $> go list -m all
" let g:go_debug=['shell-commands','lsp']
let g:go_updatetime = 50 " ms
let g:go_auto_sameids = 1
let g:go_auto_type_info = 1
let g:go_metalinter_command = "golangci-lint"
let g:go_metalinter_enabeld = ['deadcode', 'errcheck', 'gosimple', 'govet', 'staticcheck', 'typecheck', 'unused', 'varcheck']
let g:go_metalinter_autosave = 0
let g:go_metalinter_autosave_enabeld = ['deadcode', 'errcheck', 'gosimple', 'govet', 'staticcheck', 'typecheck', 'unused', 'varcheck']
" let g:go_list_type = "quickfix"
" let g:go_list_type_commands = { "GoMetaLinterAutoSave": "locationlist" }
" let g:go_list_autoclose = 1
let g:go_fmt_command = "goimports"
" let g:go_fmt_options = {
"     \ 'goimports': '-local git.zuoyebang.cc',
"     \ }
let g:go_def_mapping_enabled = 0
let g:go_def_mode = 'gopls'
" let g:go_def_mode = 'godef'
let g:go_play_browser_command = "chrome"
let g:go_doc_popup_window = 1

" Plugin 'SirVer/ultisnips'
let g:UltiSnipsExpandTrigger="<right>"

" Plugin 'neoclide/coc.nvim'
let g:coc_start_at_startup = 1
" let g:coc_global_extensions = ['coc-json', 'coc-git']

" To make <cr> select the first completion item and confirm the completion when no item has been selected
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"


" Plugin 'Valloric/YouCompleteMe'
let g:ycm_auto_trigger = 0
let g:ycm_min_num_of_chars_for_completion = 99
let g:ycm_auto_hover = -1
" let g:ycm_server_keep_logfiles = 1
" let g:ycm_server_log_level = 'debug'
" let g:ycm_python_binary_path = 'python'
" let g:ycm_path_to_python_interpreter='/usr/bin/python3'
let g:ycm_autoclose_preview_window_after_insertion = 1

" Plugin 'dense-analysis/ale'
" Use :ALEInfo to check linters, and pip install linter binaries before you use them.
let g:ale_set_balloons = 0
let g:ale_completion_enabled = 0
let g:ale_fixers = {
      \   '*': ['remove_trailing_lines', 'trim_whitespace'],
      \   'python': ['autopep8', 'black', 'isort', 'autoflake', 'remove_trailing_lines', 'trim_whitespace'],
      \}
" python linters
let g:ale_python_flake8_options = '--max-line-length 88 --ignore E203'
let g:ale_python_mypy_options = '--ignore-missing-imports'
let g:ale_python_pyright_config = {
      \     'python': {
        \      'pythonPath': '/usr/local/bin/python3',
        \      'analysis': {
          \      'diagnosticSeverityOverrides': {'reportMissingImports': 'none'}
          \    },
          \ },
          \}

" python fixers
" https://pycqa.github.io/isort/docs/configuration/options.html
let g:ale_python_isort_options = '--line-length 88 --multi-line 3 --combine-as --trailing-comma --project interface --project webapps'
let g:ale_python_autopep8_options = '--max-line-length 88'
" let g:ale_python_black_options = '--line-length 88 --skip-string-normalization'
let g:ale_python_black_options = '--line-length 88'
let g:ale_python_autoflake_options = '--remove-all-unused-imports'
let g:ale_fix_on_save = 1
let g:ale_fix_on_save_ignore = {
      \   'python': ['autopep8', 'black', 'autoflake'],
      \}
if executable("autoflake") != 1
  echoerr "command not found: autoflake, $> pip install --upgrade autoflake"
endif
if executable("autopep8") != 1
  echoerr "command not found: autopep8, $> pip install autopep8"
endif
if executable("flake8") != 1
  echoerr "command not found: flake8, $> pip install --upgrade flake8"
endif

" Plugin 'davidhalter/jedi-vim'
let g:jedi#goto_command = "gd"
let g:jedi#completions_enabled = 0
let g:jedi#smart_auto_mappings = 1
" let g:jedi#force_py_version= "3.8" " :python3 import sys; print(sys.version)
let g:jedi#show_call_signatures = "1"
" let g:jedi#environment_path = "venv"
" let g:jedi#added_sys_path = []

" Plugin 'mileszs/ack.vim'
let g:ackprg = 'ag --vimgrep'
if executable("ag") != 1
  echoerr "command not found: ag, check https://github.com/ggreer/the_silver_searcher#installing"
endif
let g:ack_use_dispatch = 1
let g:ack_apply_qmappings = 0
let g:ack_mappings = {
      \ "t": "<C-W><CR><C-W>T",
      \ "T": "<C-W><CR><C-W>TgT<C-W>j",
      \ "o": "<CR>",
      \ "O": "<CR>:ccl<CR>",
      \ "go": "<CR><C-W>j",
      \ "h": "",
      \ "H": "<C-W><CR><C-W>K<C-W>b",
      \ "s": "<C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t<C-W>R",
      \ "v": "",
      \ "gv": "<C-W><CR><C-W>H<C-W>b<C-W>J" }

" Plugin 'tpope/vim-abolish'
" MixedCase (crm), camelCase (crc), snake_case (crs), UPPER_CASE (cru), dash-case (cr-), dot.case (cr.), space case (cr<space>), and Title Case (crt)

" Plugin 'ctrlpvim/ctrlp.vim'
let g:ctrlp_cmd = 'CtrlPMRU'
" let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_max_files = 0
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<2-LeftMouse>'],
    \ 'AcceptSelection("t")': ['<cr>'],
    \ }

" Plugin 'mhinz/vim-startify'
let g:startify_custom_header = ''
let g:startify_lists = [
      \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
      \ { 'type': 'files',     'header': ['   MRU']            },
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ { 'type': 'commands',  'header': ['   Commands']       },
      \ ]
" let g:startify_bookmarks = [
"       \  {'v': '/Users/sangchuang/go/src/awesome-dev-tools/vimrc'},
"       \  {'z': '/Users/sangchuang/go/src/awesome-dev-tools/zshrc'}
"       \]
" let g:startify_session_autoload    = 1
" let g:startify_session_persistence = 1
let g:startify_change_to_vcs_root = 1

" Plugin 'ryanoasis/vim-devicons'
" https://github.com/ryanoasis/nerd-fonts#font-installation
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_airline_statusline = 0

" Plugin 'majutsushi/tagbar'
let g:tagbar_autoclose = 1

" Plugin 'iamcco/markdown-preview.nvim'
let g:mkdp_auto_start = 0

" Plugin 'mbbill/undotree'
let g:undotree_CustomUndotreeCmd = 'vertical 31 new'

" Plugin 'ludovicchabant/vim-gutentags'
let g:gutentags_cache_dir = '~/.vim/gutentags'
let g:gutentags_add_default_project_roots = 0
let g:gutentags_project_root = ['.git']
let g:gutentags_ctags_extra_args = [
      \ '--tag-relative=yes',
      \ '--fields=+ailmnS',
      \ ]

" Plugin 'puremourning/vimspector'
" let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_install_gadgets = [ 'vscode-go', 'debugpy', 'vscode-bash-debug', 'vscode-cpptools', 'CodeLLDB' ]

" Plugin 'luochen1990/rainbow'
let g:rainbow_active = 1
let g:rainbow_conf = {
      \ 'separately': {'nerdtree': 0}
      \ }

" Plugin 'jreybert/vimagit'
let g:magit_default_fold_level=2
let g:magit_auto_close=1

" Plugin 'AndrewRadev/linediff.vim'
autocmd User LinediffBufferReady
      \ NERDTreeClose |
      \ nnoremap <buffer> q :LinediffReset<CR> |
      \ let g:go_fmt_autosave = 0 |
      \ let g:go_metalinter_autosave = 0

" Plugin 'vim-test/vim-test'
let test#strategy = "dispatch" " make test commands execute using dispatch.vim

" Persistent undo, even if you close and reopen Vim
set undodir=~/.vim/undo-dir
set undofile
if !isdirectory(&undodir)
  echoerr &undodir "not found"
endif

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null

" Quick replay micro at q
nnoremap <Space> @q

" Do not redraw screen in the middle of a macro. Makes them complete faster.
set lazyredraw

" When there is a previous search pattern, highlight all its matches.
noremap n :set hlsearch<cr>n
noremap N :set hlsearch<cr>N
noremap / :set hlsearch<cr>/
noremap ? :set hlsearch<cr>?
autocmd CursorHold * set nohlsearch

nnoremap gd <C-]>
autocmd Filetype go nnoremap gd :GoDef<CR>:sleep 20m<CR>zO
" nnoremap gt :YcmCompleter GoToType<CR>
nnoremap gt :GoDefType<CR>

" Moving between viewports
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Operating quickfix/location list item
" quit
autocmd FileType qf nnoremap <buffer> q :q<CR>
" open in new tab
autocmd FileType qf nnoremap <buffer> t <C-W><CR><C-W>T
" open in new tab silently
autocmd FileType qf nnoremap <buffer> T <C-W><CR><C-W>TgT<C-W>j
" open vsplit
autocmd FileType qf nnoremap <buffer> s <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t<C-W>R

" Disable Ex mode
nnoremap Q <Nop>

" Displaying images in the terminal
autocmd BufEnter *.png,*.jpg,*gif exec "! ~/.iterm2/imgcat ".expand("%") | :bw

" Sort target file lines on save
autocmd BufWritePre */requirements.txt :sort i
autocmd BufWritePre */requirements.txt :g/^\s*$/d

" Set the title of the Terminal to the current open file
function! SetTerminalTitle()
  if len(&buftype) > 0
    return
  endif

  " this is the format iTerm2 expects when setting the window title
  let args = "\033];".expand('%:t')."\007"
  silent! execute '!echo -ne "'.args.'"'
endfunction

autocmd BufEnter * call SetTerminalTitle()

" Apple > System Preferences > Keyboard > Touch bar App Control
" iTerm2 > View > Customize Touch Bar > Drag the Function keys onto the Touch Bar
function! ToggleDebugMode(...)
  if !g:debug_mode
    silent !$HOME/.iterm2/it2setkeylabel set F1 Stop⏹
    silent! unmap <F1>
    nmap <F1>         <Plug>VimspectorStop

    silent !$HOME/.iterm2/it2setkeylabel set F2 Restart🔄
    silent! unmap <F2>
    nmap <F2>         <Plug>VimspectorRestart

    silent !$HOME/.iterm2/it2setkeylabel set F3 Continue▶️
    silent! unmap <F3>
    nmap <F3>         <Plug>VimspectorContinue
    nmap <leader><F3> <Plug>VimspectorLaunch

    silent !$HOME/.iterm2/it2setkeylabel set F4 Pause⏸
    silent! unmap <F4>
    nmap <F4>         <Plug>VimspectorPause

    silent !$HOME/.iterm2/it2setkeylabel set F5 Break🔴
    silent! unmap <F5>
    silent! unmap <buffer> <F5>
    augroup F5Group
      autocmd!
    augroup END
    nmap <F5>         <Plug>VimspectorToggleBreakpoint
    nmap <leader><F5> <Plug>VimspectorToggleConditionalBreakpoint

    silent !$HOME/.iterm2/it2setkeylabel set F6 StepOver⏩
    silent! unmap <F6>
    nmap <F6>        <Plug>VimspectorStepOver

    silent !$HOME/.iterm2/it2setkeylabel set F7 StepInto⤵️
    silent! unmap <F7>
    nmap <F7>        <Plug>VimspectorStepInto

    silent !$HOME/.iterm2/it2setkeylabel set F8 StepOut⤴️
    silent! unmap <F8>
    nmap <F8>        <Plug>VimspectorStepOut

    silent! unmap <F9>
    nmap <F9>         <Plug>VimspectorAddFunctionBreakpoint
    nmap <leader><F9> <Plug>VimspectorRunToCursor

    let g:debug_mode = 1
    silent !echo -e "\033]50;SetProfile=GuakeTinyFont\a"
  else
    silent !$HOME/.iterm2/it2setkeylabel set F1 Help❔

    " F2: save and build
    silent !$HOME/.iterm2/it2setkeylabel set F2 Build🛠
    nnoremap <F2> :update<CR>:lclose<CR>:Dispatch make<CR>
    noremap! <F2> <ESC>:update<CR>:lclose<CR>:Dispatch make<CR>

    " F3: save and test
    silent !$HOME/.iterm2/it2setkeylabel set F3 Test☑️
    nnoremap <F3> :update<CR>:TestFile<CR>

    " F4: git blame
    silent !$HOME/.iterm2/it2setkeylabel set F4 Blame🔎
    nnoremap <F4> :Git blame<CR>
    vnoremap <F4> :GV!<CR>

    " F5: save and run
    silent !$HOME/.iterm2/it2setkeylabel set F5 Run🏃
    augroup F5Group
      autocmd!
      autocmd Filetype c,cpp      noremap <buffer> <F5> :make clean <CR> :update <Bar> execute '!make test && ./test'<CR>
      autocmd Filetype go         noremap <buffer> <F5> :update <Bar> Dispatch Dummy=dummy go run %<CR>
      autocmd Filetype go         noremap! <buffer> <F5> <ESC>:update <Bar> Dispatch Dummy=dummy go run %<CR>
      autocmd Filetype lua        noremap <buffer> <F5> :update <Bar> execute '!lua '.shellescape(@%, 1)<CR>
      autocmd Filetype javascript noremap <buffer> <F5> :update <Bar> execute '!node '.shellescape(@%, 1)<CR>
      autocmd Filetype php        noremap <buffer> <F5> :update <Bar> Dispatch D=d php % <CR>
      " autocmd Filetype matlab     noremap <buffer> <F5> :update <Bar> execute '!octave '.shellescape(@%, 1)<CR>
      autocmd Filetype python     noremap <buffer> <F5> :update <Bar> Dispatch MPLBACKEND= python3 %<CR>
      autocmd Filetype python     noremap! <buffer> <F5> <ESC>:update <Bar> Dispatch MPLBACKEND= python3 %<CR>
      autocmd Filetype sh         noremap <buffer> <F5> :update <Bar> Dispatch D=d ./%<CR>
      autocmd Filetype sh         noremap! <buffer> <F5> <ESC>:update <Bar> Dispatch D=d ./%<CR>
      " autocmd Filetype sql        noremap <buffer> <F5> :update <Bar> execute '!/Users/sangchuang/Documents/python/xcpython/zuiyou/odpscmd/bin/odpscmd -f '.shellescape(@%, 1)<CR>
      autocmd Filetype tex        noremap <buffer> <F5> <ESC>:update <Bar> execute '!pdflatex '.shellescape(@%, 1)<CR>
    augroup END
    if @% != ""
      e " Reload the current file to fire autocmd on Filetype
    endif

    " F6: log.Debug
    silent !$HOME/.iterm2/it2setkeylabel set F6 Debug💡
    function! GolangDebug(...)
    	call feedkeys("olog.DebugfCtx(ctx, \<CR>\"\<ESC>")
      call feedkeys("pa,\<ESC>")
      call feedkeys(":s/,/: %+v,/g\<CR>$i\"\<ESC>")
      call feedkeys("A \<ESC>pA)\<ESC>")
      call feedkeys(':s/\(\w\)\@<= [a-zA-Z0-9*.\[\]{}]\+//ge')
      call feedkeys("\<CR>kJ")

      call feedkeys(':s/"ctx: %+v, /"/')
      call feedkeys("\<CR>")
      call feedkeys(':s/, ctx, /, /')
      call feedkeys("\<CR>")
    endfunction
    function! PythonDebug(...)
      call feedkeys('o.info(f"')
      call feedkeys("\<CR>\<ESC>pa,\<ESC>")
      call feedkeys(':s/\([^,]*\),\( \|\)/{\1=}, /g')
      call feedkeys("\<CR>$xxa\")\<ESC>kJxIlogger\<ESC>")
    endfunction
    function! Debug(...)
      if &filetype == 'python'
        return call('PythonDebug', a:000)
      elseif &filetype == 'go'
        return call('GolangDebug', a:000)
      endif
    endfunction
    noremap <F6> vi(y:call Debug('<C-R>=escape(@",'/\')<CR>')<CR>
    vnoremap <F6> y:call Debug('<C-R>=escape(@",'/\')<CR>')<CR>
    noremap <S-F6> vi(yolog.Debugf("<ESC>pa,<ESC>:s/,/: %v,/g<CR>$i"<ESC>A <ESC>pA)<ESC>:s/\(\w\)\@<= [a-zA-Z0-9*.\[\]{}]\+//ge<CR>
    vnoremap <S-F6> yolog.Debugf("<ESC>pa,<ESC>:s/,/: %v,/g<CR>$i"<ESC>A <ESC>pA)<ESC>:s/\(\w\)\@<= [a-zA-Z0-9*.\[\]{}]\+//ge<CR>

    " F7: log.Error
    silent !$HOME/.iterm2/it2setkeylabel set F7 Error🆘
    function! Error(...)
      call feedkeys("oif err != nil {\<CR>")
      call feedkeys("log.ErrorfCtx(ctx,\<CR>\"\<ESC>")
      call feedkeys("phdi(hi err, \<ESC>pa, \<ESC>")
      call feedkeys(':s/,/: %+v,/ge')
      call feedkeys("\<CR>f(hhi\", err\<ESC>llplxkJ")
      call feedkeys("oreturn\<CR>}\<ESC>kk")

      call feedkeys(':s/, \([a-zA-Z]\+\.\|\)[Cc]tx\(\|: %+v\), /, /g')
      call feedkeys("\<CR>")
    endfunction
    noremap <F7> y$:call Error('<C-R>=escape(@",'/\')<CR>')<CR>
    noremap <S-F7> y$oif err != nil {<CR>log.Errorf("<ESC>phdi(hi err, <ESC>pa, <ESC>:s/,/: %v,/ge<CR>2f(hhi", err<ESC>llplxoreturn<CR>}<ESC>

    " F8/9: switch between nerd tree tabs
    silent !$HOME/.iterm2/it2setkeylabel set F8 ⬅️
    silent !$HOME/.iterm2/it2setkeylabel set F9 ➡️
    noremap <F8> gT
    noremap <F9> gt
    noremap! <F8> <ESC>gT
    noremap! <F9> <ESC>gt

    let g:debug_mode = 0
    silent !echo -e "\033]50;SetProfile=Guake\a"
  endif
endfun

let g:debug_mode = 1
silent call ToggleDebugMode() " Default debug mode off
autocmd User VimspectorUICreated NERDTreeClose

" available options k

" option + a: [A]LE fix problems with the current buffer.
" Reload the current file to fire autocmd on Filetype
noremap å :e<CR>
autocmd Filetype python nnoremap å :ALEFix<CR>
autocmd Filetype python vnoremap å !black - -q<CR>
autocmd Filetype sql nnoremap å :%!sqlformat --reindent --keywords upper --identifiers lower -<CR>
autocmd Filetype sql vnoremap å :!sqlformat --reindent --keywords upper --identifiers lower -<CR>

" option + b: add Golang struct [B]SON tag
" noremap ∫ :call BSON()<CR>

" option + b: toggle [b]reakpoint debug mode
noremap ∫ :call ToggleDebugMode()<CR>:redraw!<CR>

" option + c: show the set of identifiers that refer to the same object as does the selected identifier.
noremap ç :GoReferrers<CR>
" option + C: show implements relation for a selected package
noremap Ç :GoImplements

" option + d: git [d]iff split current file
nnoremap ∂ :Gvdiffsplit<CR>
" Linediff does not work on fold with nerdtree
vnoremap ∂ :Linediff<CR>zR

" option + f: [f]ind the word under cursor in the current project
nnoremap ƒ :w<CR>:let g:ack_use_dispatch = 1<CR>:Ack! --literal --word-regexp '<cword>' <CR>:let g:ack_use_dispatch = 0<CR>
vnoremap ƒ y:let g:ack_use_dispatch = 1<CR>:Ack! --literal --word-regexp '<C-R>=escape(@",'/\')<CR>' <CR>:let g:ack_use_dispatch = 0<CR>

" option + F: [f]ind the word under cursor in all projects
nnoremap Ï :w<CR>:let g:ack_use_dispatch = 1<CR>:Ack! --literal --word-regexp '<cword>' ..<CR>:let g:ack_use_dispatch = 0<CR>
vnoremap Ï y:let g:ack_use_dispatch = 1<CR>:Ack! --literal --word-regexp '<C-R>=escape(@",'/\')<CR>' ..<CR>:let g:ack_use_dispatch = 0<CR>

" option + g: [g]oogle search the word under cursor
nnoremap © :!open -a "Google Chrome" 'https://google.com/search?q=<cword>'<CR><CR>
vnoremap © y:!open -a "Google Chrome" 'https://google.com/search?q='<C-R>=escape(@",'/\')<CR><CR><CR>

" option + h: nerdTree <-> undoTree [h]istory
noremap ˙ :NERDTreeToggle<CR>:UndotreeToggle<CR>

" option + j: add Golang struct [J]SON tag
noremap ∆ :call JSON()<CR>
" option + J: add Golang struct [J]SON tag and gorm tag
noremap Ô :call GORM()<CR>

" option + l: [l]ist tagbars
noremap ¬ :TagbarToggle<CR>

" option + m: git diff split current file to [m]aster
nnoremap µ :Gvdiffsplit master<CR>

" option + o: add Golang struct JSON & BSON tag along with [o]mitempty
noremap ø :call OmitemptyBSON()<CR>

" option + p: copy cursor [p]osition to system clipboard
noremap π :cd ..<CR>:call setreg("+", @% . " +" . line("."))<CR>:cd -<CR>:echo getreg("+")<CR>
vnoremap π "+y:cd ..<CR>:call setreg("+", "// " . @% . " +" . line(".") . "\n" . getreg("+"))<CR>:cd -<CR>:echo getreg("+")<CR>

" option + q: format JSON with j[q]
nnoremap œ va{:!jq -S<CR>
vnoremap œ !jq<CR>

" option + r: [r]eload vim[r]c
noremap ® :source ~/.vimrc<CR>:e<CR>:call go#lsp#Restart()<CR>

" option + s: [s]olve git merge conflict
noremap ß :NERDTreeClose<CR>:Gvdiffsplit!<CR>
" diff get local (left)
nnoremap dgl :diffget //2<CR>
" diff get upstream
nnoremap dgu :diffget //3<CR>
" diff get right
nnoremap dgr :diffget //3<CR>

" option + t: add new TODO line
nnoremap † o# TODO(chad.sang)<SPACE>
" option + T: findall [T]ODOs ingolang codes
nnoremap ˇ :Ack! --literal 'TODO(chad.sang)'<CR>

" option + v: find and re[v]eal the file for the active buffer in the NERDTree window
nnoremap √ :NERDTreeFind<CR>

" option + w: [w]rite and unfold current line, also works when goimports stuck
" noremap ∑ :let g:go_fmt_command = "gofmt"<CR>:w<CR>zO :let g:go_fmt_command = "goimports"<CR>
" noremap! ∑ <ESC>:let g:go_fmt_command = "gofmt"<CR>:w<CR>zO :let g:go_fmt_command = "goimports"<CR>

" option + w: Toggle [w]rap mode
noremap ∑ :call ToggleWrap()<CR>

" option + y: calc expression
nnoremap \ 0vg_yA=<C-R>=<C-R>"<CR><Esc>
vnoremap \ yA=<C-R>=<C-R>"<CR><Esc>

function! CloseNomodifiableBuffers()
  let i = 0
  let n = bufnr('$')
  while i < n
    let i = i + 1
    if bufloaded(i) && !getbufvar(i, '&modifiable') && getbufvar(i, '&filetype') != 'nerdtree'
      exe 'bd ' . i
    endif
  endwhile
endfun

" option + x: close all nomodifiable buffers
noremap ≈ :call CloseNomodifiableBuffers()<CR>

" option + z: Run current line in [Z]sh
noremap Ω :execute "Dispatch " . getline('.')<CR>:copen 20<CR><C-w><C-p>:NERDTreeClose<CR>

" option + -: height -1
noremap – <C-w>-
" option + =: height +1
noremap ≠ <C-w>+
" option + ,: width -1
noremap ≤ <C-w><
" option + .: width +1
noremap ≥ <C-w>>

function! ToggleWrap(...)
  if (&wrap == 1)
    set nowrap
    unmap j
    unmap k
  else
    set wrap
    nnoremap j gj
    nnoremap k gk
  endif
endfunction

function! JSON(...)
	call feedkeys("^hyeo\<ESC>p")
	" call CamelToUnderscore()
	call Uncapitalize()
	call feedkeys("kA \<ESC>")
	call feedkeys('Jdea`json:"')
	call feedkeys("\<ESC>")
	call feedkeys('pa"`')
	call feedkeys("\<ESC>j^")
endfunction

function! GORM(...)
	call feedkeys("^hyeo\<ESC>p")
	call CamelToUnderscore()
	call feedkeys("kA \<ESC>")
	call feedkeys('Jdea`gorm:"column:')
	call feedkeys("\<ESC>")
	call feedkeys('pa" json:"')
	call feedkeys("\<ESC>")
	call feedkeys('pa"`')
	call feedkeys("\<ESC>j^")
endfunction

function! BSON(...)
	call feedkeys("^hyeo\<ESC>p")
	call CamelToUnderscore()
	call feedkeys("kA \<ESC>")
	call feedkeys('Jdea`json:"')
	call feedkeys("\<ESC>")
	call feedkeys('pa" bson:"')
	call feedkeys("\<ESC>")
	call feedkeys('pa"`')
	call feedkeys("\<ESC>j^")
endfunction

function! OmitemptyBSON(...)
	call feedkeys("^hyeo\<ESC>p")
	call CamelToUnderscore()
	call feedkeys("kA \<ESC>")
	call feedkeys('Jdea`json:"')
	call feedkeys("\<ESC>")
	call feedkeys('pa,omitempty" bson:"')
	call feedkeys("\<ESC>")
	call feedkeys('pa,omitempty"`')
	call feedkeys("\<ESC>j^")
endfunction

function! Uncapitalize(...)
	call feedkeys('b~')
endfunction

function! CamelToUnderscore(...)
	call feedkeys(':s/\([a-z]\)\([A-Z]\)\@=/\1_/ge')
	call feedkeys("\<CR>")
	call feedkeys(':s/\([A-Z]\)\([A-Z][a-z]\)\@=/\1_/ge')
	call feedkeys("\<CR>")
	call feedkeys(':s/\([A-Z]\)/\L\1/ge')
	call feedkeys("\<CR>")
endfunction

function MyCursorHold(...)
  let word = expand('<cword>')
  if word =~ '^[0-9]\{10\}$'
    if popup_list()->len() == 0
      call popup_create(strftime("%Y-%m-%d %H:%M:%S", word), #{pos: 'botleft', line: 'cursor-1', col: 'cursor', border: [], moved: 'word', wrap: 0})
    endif
  endif
endfunction
autocmd CursorHold * call MyCursorHold()