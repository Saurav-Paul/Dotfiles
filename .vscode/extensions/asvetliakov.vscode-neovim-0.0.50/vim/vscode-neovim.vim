" Set global flag to allow checking in custom user config
let g:vscode = 1

let s:currDir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
" Adjust rtp path
let &runtimepath = &runtimepath . ',' . s:currDir . '/vim-altercmd'

" Used to execute vscode command
let s:vscodeCommandEventName = "vscode-command"
" Used to execute vscode command with some range (the specified range will be selected and the command will be executed on this range)
let s:vscodeRangeCommandEventName = "vscode-range-command"
" Used for externsion inter-communications
let s:vscodePluginEventName = "vscode-neovim"

" RPC and global functions

function! VSCodeCall(cmd, ...)
    call rpcrequest(g:vscode_channel, s:vscodeCommandEventName, a:cmd, a:000)
endfunction

function! VSCodeCallRange(cmd, line1, line2, leaveSelection, ...)
    call rpcrequest(g:vscode_channel, s:vscodeRangeCommandEventName, a:cmd, a:line1, a:line2, 0, 0, a:leaveSelection, a:000)
endfunction

function! VSCodeCallRangePos(cmd, line1, line2, pos1, pos2, leaveSelection, ...)
    call rpcrequest(g:vscode_channel, s:vscodeRangeCommandEventName, a:cmd, a:line1, a:line2, a:pos1, a:pos2, a:leaveSelection, a:000)
endfunction

function! VSCodeNotify(cmd, ...)
    call rpcnotify(g:vscode_channel, s:vscodeCommandEventName, a:cmd, a:000)
endfunction

function! VSCodeNotifyRange(cmd, line1, line2, leaveSelection, ...)
    call rpcnotify(g:vscode_channel, s:vscodeRangeCommandEventName, a:cmd, a:line1, a:line2, 0, 0, a:leaveSelection, a:000)
endfunction

function! VSCodeNotifyRangePos(cmd, line1, line2, pos1, pos2, leaveSelection, ...)
    call rpcnotify(g:vscode_channel, s:vscodeRangeCommandEventName, a:cmd, a:line1, a:line2, a:pos1, a:pos2, a:leaveSelection, a:000)
endfunction

function! VSCodeExtensionCall(cmd, ...)
    call rpcrequest(g:vscode_channel, s:vscodePluginEventName, a:cmd, a:000)
endfunction

function! VSCodeExtensionNotify(cmd, ...)
    call rpcnotify(g:vscode_channel, s:vscodePluginEventName, a:cmd, a:000)
endfunction

" Called from extension when opening/creating new file in vscode to reset undo tree
function! VSCodeClearUndo(bufId)
    let oldlevels = &undolevels
    call nvim_buf_set_option(a:bufId, 'undolevels', -1)
    call nvim_buf_set_lines(a:bufId, 0, 0, 0, [])
    call nvim_buf_set_option(a:bufId, 'undolevels', oldlevels)
    unlet oldlevels
endfunction

" Called from extension to align screen row in neovim after scrolling
" function! VSCodeAlignScreenRow(row)
"     let currentRow = winline()
"     let diff = abs(currentRow - a:row)
"     if diff > 0
"         if (a:row - currentRow) < 0
"             if diff > 1
"                 silent! exe "normal! " . diff . "\<C-e>"
"             else
"                 silent! exe "normal! \<C-e>"
"             endif
"         else
"             if diff > 1
"                 silent! exe "normal! " . diff . "\<C-y>"
"             else
"                 silent! exe "normal! \<C-y>"
"             endif
"         endif
"     endif
" endfunction

" Set text decorations for given ranges. Used in easymotion
function! VSCodeSetTextDecorations(hlName, rowsCols)
    call VSCodeExtensionNotify('text-decorations', a:hlName, a:rowsCols)
endfunction

" Used for ctrl-a insert keybinding
function! VSCodeGetLastInsertText()
    let line1 = line("'[")
    let line2 = line("']")
    if (line1 == 0)
        return []
    endif
    let lines = []
    for i in range(line1, line2)
        call add(lines, getline(i))
    endfor
    return lines
endfunction

" Used for ctrl-r [reg] insert keybindings
function! VSCodeGetRegister(reg)
    return getreg(a:reg)
endfunction

function! VSCodeClearJumpIfFirstWin()
    let currWin = nvim_get_current_win()
    if currWin == g:vscode_primary_win && w:vscode_clearjump
        let w:vscode_clearjump = 0
        clearjumps
    endif
endfunction

function! VSCodeStoreJumpForWin(winId)
    " Seems causing troubles
    " let currWin = nvim_get_current_win()
    " if currWin != a:winId
    "     call nvim_set_current_win(a:winId)
    " endif
    exe "normal! m'"
    " if currWin != a:winId
    "     call nvim_set_current_win(currWin)
    " endif
endfunction

" This is called by extension when created new buffer
function! s:onBufEnter(name, id)
    set conceallevel=0
    let tabstop = &tabstop
    let isJumping = 0
    if exists("g:isJumping")
        let isJumping = g:isJumping
    endif
    call VSCodeExtensionCall('external-buffer', a:name, a:id, 1, tabstop, isJumping)
endfunction

function! s:onWinEnter()
    if exists("w:vscode_clearjump") && w:vscode_clearjump
        let w:vscode_clearjump = 0
        clearjumps
    endif
endfunction

function! s:runFileTypeDetection()
    doautocmd BufRead
    " make sure we disable syntax (global option seems doesn't take effect for 2nd+ windows)
    set syntax=off
endfunction

function! s:onInsertEnter()
    let reg = reg_recording()
    if reg != ""
        call VSCodeExtensionCall('notify-recording', reg)
    endif
endfunction


" Load altercmd first
execute 'source ' . s:currDir . '/vim-altercmd/plugin/altercmd.vim'
execute 'source ' . s:currDir . '/vscode-insert.vim'
execute 'source ' . s:currDir . '/vscode-scrolling.vim'
execute 'source ' . s:currDir . '/vscode-jumplist.vim'
execute 'source ' . s:currDir . '/vscode-code-actions.vim'
execute 'source ' . s:currDir . '/vscode-file-commands.vim'
execute 'source ' . s:currDir . '/vscode-tab-commands.vim'
execute 'source ' . s:currDir . '/vscode-window-commands.vim'

" autocmd BufWinEnter,WinNew,WinEnter * :only
autocmd BufEnter * call <SID>onBufEnter(expand('<afile>'), expand('<abuf>'))
" Help and other buffer types may explicitly disable line numbers - reenable them, !important - set nowrap since it may be overriden and this option is crucial for now
autocmd FileType * :setlocal conceallevel=0 | :setlocal number | :setlocal numberwidth=8 | :setlocal nowrap | :setlocal nofoldenable
autocmd WinEnter * call <SID>onWinEnter()
autocmd InsertEnter * call <SID>onInsertEnter()
autocmd BufAdd * call <SID>runFileTypeDetection()
" Looks like external windows are coming with "set wrap" set automatically, disable them
autocmd WinNew,WinEnter * :set nowrap
