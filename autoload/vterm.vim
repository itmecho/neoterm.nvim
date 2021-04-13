function! vterm#toggle()
    lua require('vterm').toggle()
endfunction

function! vterm#send_command(cmd)
    call v:lua.require('vterm').send_command(a:cmd)
endfunction

function! vterm#rerun_command()
    call v:lua.require('vterm').rerun_command()
endfunction

function! vterm#close()
    call v:lua.require('vterm').close()
endfunction
