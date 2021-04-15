function! vterm#toggle()
    lua require('vterm').toggle()
endfunction

function! vterm#interactive()
    lua require('vterm').interactive()
endfunction

function! vterm#run(cmd)
    call v:lua.require('vterm').run(a:cmd)
endfunction

function! vterm#rerun()
    call v:lua.require('vterm').rerun()
endfunction

function! vterm#exit()
    call v:lua.require('vterm').exit()
endfunction
