command! -bang          VtermToggle       call vterm#toggle()
command! -bang -nargs=+ VtermSendCommand  call vterm#send_command('<args>')
command! -bang          VtermRerunCommand call vterm#rerun_command()
command! -bang          VtermClose        call vterm#close()
