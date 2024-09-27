local state = {
  winh = nil,
  bufh = nil,
  chan = nil,
  last_command = nil,
  last_position = nil,
}

local config = {
  clear_on_run = true,
  position = "right", -- Default position is right
  noinsert = false,
  width = 0.5, -- Default width is 50%
  height = 1, -- Default height is 100%
}

-- Returns a bool to show if the neoterm window exists
local function win_is_open()
  return state.winh ~= nil and vim.api.nvim_win_is_valid(state.winh) == true
end

-- returns a bool to show if the buf exists
local function buf_is_valid()
  return state.bufh ~= nil and vim.api.nvim_buf_is_valid(state.bufh) == true
end

local function fire_event(event)
  vim.api.nvim_exec_autocmds("User", { pattern = event })
end

local neoterm = {}

-- Sets global configuration
-- Options:
--	clear_on_run - send the clear command before running a command with run or rerun
--	position - set where the terminal window will be displayed
--		* fullscreen (0)
--		* top (1)
--		* right (2)
--		* bottom (3)
--		* left (4)
--		* center (5)
--	noinsert - don't enter insert mode when switching to the neoterm window
--	width - set the width of the terminal window (percentage, ratio, or range between 0-1)
--	height - set the height of the terminal window (percentage, ratio, or range between 0-1)
function neoterm.setup(opts)
  opts = opts or {}

  -- Handle deprecated mode parameter
  if opts.mode then
    vim.notify("Neoterm Warning!", vim.log.levels.WARN)
    print("The 'mode' option is deprecated. Please use 'position' instead.")
    local mode_to_position = {
      vertical = "right",
      horizontal = "bottom",
      fullscreen = "fullscreen",
    }
    opts.position = mode_to_position[opts.mode] or opts.position
  end

  config.position = opts.position or config.position
  config.noinsert = opts.noinsert or config.noinsert
  config.width = opts.width or config.width
  config.height = opts.height or config.height

  -- Validate and normalize width
  local width = config.width
  if type(width) == "number" then
    if width < 0 or width > 1 then
      error("Invalid width value. Width must be between 0 and 1.")
    end
  elseif type(width) == "string" then
    if not width:match("^%d+%%$") then
      error("Invalid width value. Width must be a percentage string (e.g., '50%').")
    end
    width = tonumber(width:sub(1, -2)) / 100
  else
    error("Invalid width value. Width must be a number between 0 and 1 or a percentage string.")
  end

  -- Validate and normalize height
  local height = config.height
  if type(height) == "number" then
    if height < 0 or height > 1 then
      error("Invalid height value. Height must be between 0 and 1.")
    end
  elseif type(height) == "string" then
    if not height:match("^%d+%%$") then
      error("Invalid height value. Height must be a percentage string (e.g., '50%').")
    end
    height = tonumber(height:sub(1, -2)) / 100
  else
    error("Invalid height value. Height must be a number between 0 and 1 or a percentage string.")
  end

  config.width = width
  config.height = height

  if vim.g.neoterm_bufh ~= nil and vim.api.nvim_buf_is_valid(vim.g.neoterm_bufh) then
    state.bufh = vim.g.neoterm_bufh
  end
end

local function normalize_position(position)
  if type(position) == "string" then
    local temp_position = {
      ["fullscreen"] = 0,
      ["top"] = 1,
      ["right"] = 2,
      ["bottom"] = 3,
      ["left"] = 4,
      ["center"] = 5,
    }
    position = temp_position[position]
    if position == nil then
      error("Invalid position value. Position must be one of: fullscreen, top, right, bottom, left, center.")
    end
  end
  return position
end

-- Opens the terminal window. If it was opened previously, the same terminal buffer will be used
-- Options:
--	position - override the global config position
--	noinsert - don't enter insert mode after switching to the neoterm window
--	width - override the global config width
--	height - override the global config height
function neoterm.open(opts)
  opts = opts or {}

  local buf_created = false
  if buf_is_valid() == false then
    state.bufh = vim.api.nvim_create_buf(false, true)
    vim.g.neoterm_bufh = state.bufh
    buf_created = true
  end

  local group = vim.api.nvim_create_augroup("Neoterm", {})

  if win_is_open() ~= true then
    local ui = vim.api.nvim_list_uis()[1]

    local position = normalize_position(opts.position or config.position)
    local width = opts.width or config.width
    local height = opts.height or config.height

    -- If no height is provided and position is 'top', 'bottom', or 'center', set default height
    if config.height == 1 then
      if position == 1 or position == 3 or position == 5 then
        height = 0.5
      else
        height = config.height
      end
    end

    local winopts = {
      relative = "editor",
      style = "minimal",
      border = "single",
    }

    if position == 0 then -- fullscreen
      winopts.width = ui.width
      winopts.height = ui.height - vim.o.cmdheight - 3
      winopts.row = 0
      winopts.col = 0
    elseif position == 1 then -- top
      winopts.width = ui.width
      winopts.height = math.floor(ui.height * height) - vim.o.cmdheight - 3
      winopts.row = 0
      winopts.col = 0
    elseif position == 2 then -- right
      winopts.width = math.floor(ui.width * width)
      winopts.height = ui.height - vim.o.cmdheight - 3
      winopts.row = 0
      winopts.col = ui.width - winopts.width
    elseif position == 3 then -- bottom
      winopts.width = ui.width
      winopts.height = math.floor(ui.height * height) - vim.o.cmdheight - 3
      winopts.row = ui.height - winopts.height - vim.o.cmdheight - 3
      winopts.col = 0
    elseif position == 4 then -- left
      winopts.width = math.floor(ui.width * width)
      winopts.height = ui.height - vim.o.cmdheight - 3
      winopts.row = 0
      winopts.col = 0
    elseif position == 5 then -- center
      winopts.width = math.floor(ui.width * width)
      winopts.height = math.floor(ui.height * height) - vim.o.cmdheight - 3
      winopts.row = math.floor((ui.height - winopts.height) / 2)
      winopts.col = math.floor((ui.width - winopts.width) / 2)
    else
      error("Invalid position value. Position must be one of: fullscreen, top, right, bottom, left, center.")
    end

    state.last_position = position

    state.winh = vim.api.nvim_open_win(state.bufh, true, winopts)
    fire_event("NeotermWinOpen")
    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = string.format("%d", state.winh),
      callback = function()
        fire_event("NeotermWinClose")
      end,
      group = group,
    })

    if buf_created then
      vim.cmd([[term]])
      state.chan = vim.b.terminal_job_id
      vim.api.nvim_set_option_value("buflisted", false, { buf = state.bufh })
    end
  end

  local noinsert = config.noinsert
  if opts.noinsert ~= nil then
    noinsert = opts.noinsert
  end

  if noinsert == false then
    vim.cmd([[startinsert]])
  end

  fire_event("NeotermOpened")

  vim.api.nvim_create_autocmd("TermEnter", {
    buffer = state.bufh,
    callback = function()
      fire_event("NeotermTermEnter")
    end,
    group = group,
  })

  vim.api.nvim_create_autocmd("TermLeave", {
    buffer = state.bufh,
    callback = function()
      fire_event("NeotermTermLeave")
    end,
    group = group,
  })

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = state.bufh,
    callback = function()
      state.last_position = nil
    end,
    group = group,
  })
end

function neoterm.close()
  vim.api.nvim_win_close(state.winh, false)
  state.winh = nil
end

function neoterm.toggle()
  if win_is_open() then
    neoterm.close()
  else
    neoterm.open({ position = state.last_position })
  end
end

function neoterm.exit()
  neoterm.close()

  vim.api.nvim_chan_send(state.chan, "exit\n")
  state.chan = nil

  vim.api.nvim_buf_delete(state.bufh, { force = true })
  state.bufh = nil

  state.last_position = nil

  fire_event("NeotermExit")
end

-- Takes a command as a string and runs it in the neoterm buffer. If the window is closed, it will be toggled
-- Options:
--	clear - send clear command before running the given command
function neoterm.run(command, opts)
  opts = opts or {
    clear = config.clear_on_run,
  }

  if win_is_open() == false or state.chan == nil then
    neoterm.open()
  end

  if state.last_command ~= nil then
    -- Send <C-c> to make sure any on-going commands like log tails are stopped before running the new command
    vim.api.nvim_chan_send(state.chan, "\003\n")
  end
  state.last_command = command

  if opts.clear then
    vim.api.nvim_chan_send(state.chan, "clear\n")
  end
  vim.api.nvim_chan_send(state.chan, command .. "\n")
end

function neoterm.rerun()
  if state.last_command == nil then
    print("Last command empty")
  end
  neoterm.run(state.last_command)
end

return neoterm
