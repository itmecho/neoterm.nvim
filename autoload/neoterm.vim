function! neoterm#toggle()
    lua require('neoterm').toggle()
endfunction

function! neoterm#interactive()
    lua require('neoterm').interactive()
endfunction

function! neoterm#run(cmd)
    call v:lua.require('neoterm').run(a:cmd)
endfunction

function! neoterm#rerun()
    call v:lua.require('neoterm').rerun()
endfunction

function! neoterm#exit()
    call v:lua.require('neoterm').exit()
endfunction
