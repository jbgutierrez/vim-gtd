if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal smartindent    " use smart indentation over autoindent
setlocal smarttab       " smart tabulatin and backspace
setlocal expandtab      " To spaces to tabs 'set noexpandtab' and ':retab!'
setlocal foldmethod=indent

nmap <buffer> <silent> <leader>u :GtdMark "urgent"<CR>
nmap <buffer> <silent> <leader>i :GtdMark "important"<CR>

nmap <buffer> <silent> <leader>t :GtdMove "today"<CR>
nmap <buffer> <silent> <leader>n :GtdMove "next"<CR>
nmap <buffer> <silent> <leader>s :GtdMove "someday"<CR>

nmap <buffer> <silent> <leader>x :GtdDone<CR>
nmap <buffer> <silent> <leader>c :GtdClean 'false'<CR>
nmap <buffer> <silent> <leader>a :GtdClean 'true'<CR>
" au BufWritePost <buffer> :GtdClean

function! s:GtdMark(mark)
  let mark       = a:mark
  let line       = getline(".")
  let task       = matchstr(line, '\v^[^\(]+')
  let task_token = matchstr(line, '\v\(.+\)')[1:-2]
  let tags       = split(task_token, ', ')
  let idx        = index(tags, mark)
  if idx != -1
    call remove(tags, idx)
  else
    call add(tags, mark)
  end
  let repl = substitute(task, '\s*$', '', '')
  if len(tags) > 0
    let repl = repl . ' (' . join(tags, ', ') . ')'
  endif
  call setline(".", repl)
  " echo repl
endfunction
command! -nargs=1 GtdMark call <SID>GtdMark(<args>)

function! s:GtdMove(mark)
  let mark  = a:mark
  let line  = getline(".")
  let regex = '\v^  (\[[^\]]+\] )?'
  if match(line, '\v^  \[' . mark . '\]') > -1
    let repl = substitute(line, regex, '  ', '')
  else
    let repl = substitute(line, regex, '  ['. mark .'] ', "")
  end
  call setline(".", repl)
  " echo repl
endfunction
command! -nargs=1 GtdMove call <SID>GtdMove(<args>)

function! s:GtdDone()
  let line = getline( "." )
  if !<SID>GtdIsDone( line )
    let current_time = strftime("%Y%m%d")
    let repl         = substitute(line, '^ ', '  ' . current_time, ' ')
  else
    let repl = substitute(line, '\v^  \d{8} ', '  ', '')
  endif
  call setline(".", repl)
endfunction
command! -nargs=0 GtdDone call <SID>GtdDone()

function! s:GtdIsDone( task )
  return ( match( a:task, '^  \d\{8\} ' ) > -1 )
endfunction

let g:GtdRubyScriptPath=expand('<sfile>:p:h:h')

function! s:GtdClean(archive)
  let archive = a:archive
  if has('ruby')
    echo g:GtdRubyScriptPath
	exe ':silent 1,$!ruby "' . g:GtdRubyScriptPath . '/ruby/gtd.rb" ' . archive
  else
    call s:GtdRubyWarning()
  endif
endfunction
command! -nargs=1 GtdClean call <SID>GtdClean(<args>)

function! s:GtdRubyWarning()
  echohl WarningMsg
  echo "gtd.vim requires Vim to be compiled with Ruby support"
  echohl none
endfunction
