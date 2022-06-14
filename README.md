# Neoterm

Simple neovim terminal plugin written in lua. Terminal runs in a floating window in a configurable position.

Requires `neovim` 0.7+ for access to the lua autocmd API.

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
	clear_on_run = true, -- run clear command before user specified commands
	mode = 'vertical',   -- vertical/horizontal/fullscreen
	noinsert = false     -- disable entering insert mode when opening the neoterm window
})


local neoterm = require('neoterm')

neoterm.open()
-- Override global config on a specific open call
neoterm.open({ mode = 'horizontal', noinsert = true})
neoterm.close()
neoterm.toggle()
neoterm.run('ls')
-- Control whether or not the screen is cleared before running the command
neoterm.run('ls', {clear = false})
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

# Screenshots

## Vertical (default)
```lua
require('neoterm').open()
-- or
require('neoterm').open({mode ='vertical'})
```
![image](https://user-images.githubusercontent.com/8384983/126306361-353a61ad-dfa3-4a16-b9f3-0cc8a6a258f6.png)

## Horizontal
```lua
require('neoterm').open({mode ='horizontal'})
```
![image](https://user-images.githubusercontent.com/8384983/126306318-bd1c43e4-154a-4a52-9eff-d77dc683c38c.png)

## Fullscreen
```lua
require('neoterm').open({mode ='fullscreen'})
```
![image](https://user-images.githubusercontent.com/8384983/126306383-192ea5a2-7d5b-4267-a3b7-9cee0751c44a.png)
