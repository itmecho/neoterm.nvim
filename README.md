# Neoterm

Simple neovim terminal plugin written in lua. Terminal runs in a floating window in a configurable position.

# Usage

Neoterm provides both vim commands as well as a lua API

## Commands

Neoterm provides the following commands

| Command              | Description                                                                            |
| -------------------- | -------------------------------------------------------------------------------------- |
| `NeotermOpen`      | Open the neoterm window                                                              |
| `NeotermClose`      | Close the neoterm window                                                              |
| `NeotermToggle`      | Toggle the neoterm window                                                              |
| `NeotermRun <args>`  | Run the given command in the neoterm window                                            |
| `NeotermRerun`       | Run the previous command again                                                         |
| `NeotermExit`        | Close the neoterm window and delete the terminal buffer                                |

## Lua API

The following functions are available on the neoterm module. They map directly to the commands above

```lua
-- Setup global config
require('neoterm').setup({
	mode = 'vertical' -- vertical/horizontal/fullscreen
})


local neoterm = require('neoterm')

neoterm.open()
-- Override global config on a specific open call
neoterm.open({ mode = 'horizontal', noinsert = true})
neoterm.close()
neoterm.toggle()
neoterm.run('ls')
neoterm.rerun()
neoterm.exit()
```

# Example Keybindings

```vim
nnoremap <leader>tt <cmd>NeotermToggle<CR>
nnoremap <leader>tr :NeotermRun<space>
nnoremap <leader>tR <cmd>NeotermRerun<CR>
nnoremap <leader>tx <cmd>NeotermExit<CR>
tnoremap <leader>tn <C-\\><C-n>
tnoremap <leader>tt <cmd>NeotermToggle<CR>
tnoremap <leader>tx <cmd>NeotermExit<CR>
```
