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
  clear_on_run = true, -- Run clear command before user specified commands
  position = 'right',  -- Position of the terminal window: fullscreen (0), top (1), right (2), bottom (3), left (4), center (5) (string or integer value)
  noinsert = false,    -- Disable entering insert mode when opening the neoterm window
  width = 0.5,         -- Width of the terminal window (percentage, ratio, or range between 0-1)
  height = 1,          -- Height of the terminal window (percentage, ratio, or range between 0-1)
})


local neoterm = require('neoterm')

neoterm.open()
-- Override global config on a specific open call
neoterm.open({ position = 'bottom', noinsert = true, width = 0.7, height = 0.3 })
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

## Right (default)
```lua
require('neoterm').open()
-- or
require('neoterm').open({ position = 'right' })
-- or
require('neoterm').open({ position = 2 })
```
![position-right](https://user-images.githubusercontent.com/8384983/126306361-353a61ad-dfa3-4a16-b9f3-0cc8a6a258f6.png)

## Top
```lua
require('neoterm').open({ position = 'top', height = 0.8 })
```
![position-top](https://user-images.githubusercontent.com/8384983/126306318-bd1c43e4-154a-4a52-9eff-d77dc683c38c.png)

## Bottom
```lua
require('neoterm').open({ position = 'bottom' })
--or
require('neoterm').open({ position = 3 })
```
![position-bottom](https://user-images.githubusercontent.com/8384983/126306383-192ea5a2-7d5b-4267-a3b7-9cee0751c44a.png)

## Left
```lua
require('neoterm').open({ position = 'left', width = 0.7 })
```
![position-left](https://user-images.githubusercontent.com/8384983/126306383-192ea5a2-7d5b-4267-a3b7-9cee0751c44a.png)

## Center
```lua
require('neoterm').open({ position = 'left', width = 0.6, height = 0.6 })
```
![position-center](https://user-images.githubusercontent.com/8384983/126306383-192ea5a2-7d5b-4267-a3b7-9cee0751c44a.png)

## Fullscreen
```lua
require('neoterm').open({ position = 'fullscreen' })
-- or
require('neoterm').open({ position = 0 })
```
![position-fullscreen](https://user-images.githubusercontent.com/8384983/126306383-192ea5a2-7d5b-4267-a3b7-9cee0751c44a.png)


## Deprecation Notice

> [!WARNING]
> The mode option is deprecated. Please use the new position option instead.

#### Migration Guide

- vertical → right

- horizontal → bottom

- fullscreen → fullscreen