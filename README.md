<div align = "center">

<h1>Neoterm.nvim</h1>

<p align="center">
  <img src="https://img.shields.io/github/stars/itmecho/neoterm.nvim?style=flat-square&color=yellow" alt="Stars">
  <img src="https://img.shields.io/github/forks/itmecho/neoterm.nvim?style=flat-square" alt="Forks">
  <img src="https://img.shields.io/github/contributors/itmecho/neoterm.nvim?style=flat-square&color=pink" alt="Contributors">
  <img src="https://img.shields.io/github/license/itmecho/neoterm.nvim?style=flat-square" alt="License">
</p>

<h4>Simple floating terminal plugin for neovim written in Lua.</h4>

![title](https://github.com/user-attachments/assets/00d9942a-d650-42a3-b81e-cc9ba69fa11d)

</div>


## ⚡ Installation

Requires `neovim` 0.7+ for access to the Lua Autocmd API.

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'itmecho/neoterm.nvim',
}
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'itmecho/neoterm.nvim',
}
```


## 💡 Usage

Neoterm provides both vim commands as well as a Lua API.

### Configuration

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

### Deprecation Notice

> [!WARNING]
> The `mode` option is deprecated. Please use the new `position` option instead.

#### Migration Guide

- `mode = vertical` → `position = right`

- `mode = horizontal` → `position = bottom`

- `mode = fullscreen` → `position = fullscreen`

### Commands

Neoterm provides the following commands

| Command              | Description                                                                            |
| -------------------- | -------------------------------------------------------------------------------------- |
| `NeotermOpen`      | Open the neoterm window                                                              |
| `NeotermClose`      | Close the neoterm window                                                              |
| `NeotermToggle`      | Toggle the neoterm window                                                              |
| `NeotermRun <args>`  | Run the given command in the neoterm window                                            |
| `NeotermRerun`       | Run the previous command again                                                         |
| `NeotermExit`        | Close the neoterm window and delete the terminal buffer                                |

### Example Vim Keybindings

```vim
nnoremap <leader>tt <cmd>NeotermToggle<CR>
nnoremap <leader>tr :NeotermRun<space>
nnoremap <leader>tR <cmd>NeotermRerun<CR>
nnoremap <leader>tx <cmd>NeotermExit<CR>
tnoremap <leader>tn <C-\\><C-n>
tnoremap <leader>tt <cmd>NeotermToggle<CR>
tnoremap <leader>tx <cmd>NeotermExit<CR>
```

## 🔍 Screenshots

### `right`
```lua
require('neoterm').open()
-- or
require('neoterm').open({ position = 'right' })
-- or
require('neoterm').open({ position = 2 })
```

![position-right](https://github.com/user-attachments/assets/edcb4bcd-12a7-40b7-b95d-7658c835f69c)

### `top`
```lua
require('neoterm').open({ position = 'top', height = 0.6 })
```

![position-top](https://github.com/user-attachments/assets/18a984a2-4ea5-4f9c-a123-4631ac25bcb2)

### `bottom`
```lua
require('neoterm').open({ position = 'bottom' })
--or
require('neoterm').open({ position = 3 })
```

![position-bottom](https://github.com/user-attachments/assets/9a40db31-22b2-4e6d-9213-744e0de73498)


### `left`
```lua
require('neoterm').open({ position = 'left', width = 0.3 })
-- or
require('neoterm').open({ position = 4 })
```
![position-left](https://github.com/user-attachments/assets/9d0de2ad-af8d-4c3f-a4a8-908dc907aa14)

## Contributors

Thanks to all contributors!

<a href="https://github.com/itmecho/neoterm.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=itmecho/neoterm.nvim" />
</a>