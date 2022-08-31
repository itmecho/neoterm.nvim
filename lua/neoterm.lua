local state = {
  winh = nil,
  bufh = nil,
  chan = nil,
  last_command = nil,
  last_mode = nil,
}

local config = {
  clear_on_run = true,
  mode = "vertical",
  noinsert = false,
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
--	clear_on_run - send the clear comand before running a command with run or rerun
--	mode - set how the terminal window will be displayed
--		* vertical
--		* horizonal
--		* fullscreen
--	noinsert - don't enter insert mode when switching to the neoterm window
function neoterm.setup(opts)
  config.mode = opts.mode or config.mode
  config.noinsert = opts.noinsert or config.noinsert
  config.winopts = opts.winopts
  config.winhighlight = opts.winhighlight
end

-- Opens the terminal window. If it was opened previously, the same terminal buffer will be used
-- Options:
--	mode - override the global config mode
--	noinsert - don't enter insert mode after switching to the neoterm window
function neoterm.open(opts)
  opts = opts or {}

  local buf_created = false
  if buf_is_valid() == false then
    state.bufh = vim.api.nvim_create_buf(false, true)
    buf_created = true
  end

  local group = vim.api.nvim_create_augroup("Neoterm", {})

  if win_is_open() ~= true then
    local ui = vim.api.nvim_list_uis()[1]
    local winopts = {
      relative = "editor",
      width = math.floor(ui.width / 2),
      height = ui.height - vim.o.cmdheight - 3,
      row = 0,
      col = ui.width,
      style = "minimal",
      border = "single",
    }

    local wo = opts.winopts or config.winopts
    local mode = wo and "custom" or opts.mode or config.mode
    if wo then
      wo = type(wo) == "function" and wo() or wo
      if type(wo) == "table" then
        winopts = vim.tbl_extend("keep", wo, winopts)
      end
    elseif mode == "horizontal" then
      winopts.width = ui.width
      winopts.height = math.floor((ui.height - vim.o.cmdheight - 2) / 3)
      winopts.row = (2 * winopts.height)
      winopts.col = 1
    elseif mode == "fullscreen" then
      winopts.width = ui.width
      winopts.col = 1
    end

    state.last_mode = mode
    state.winh = vim.api.nvim_open_win(state.bufh, true, winopts)

    local wh = opts.winhighlight or config.winhighlight
    if wh then
      wh = type(wh) == "function" and wh() or wh
      vim.api.nvim_win_set_option(state.winh, "winhighlight", wh)
    end

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
      vim.api.nvim_buf_set_name(state.bufh, "neoterm")
      vim.api.nvim_buf_set_option(state.bufh, "buflisted", false)
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
      state.last_mode = nil
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
    neoterm.open({ mode = state.last_mode })
  end
end

function neoterm.exit()
  neoterm.close()

  vim.api.nvim_chan_send(state.chan, "exit\n")
  state.chan = nil

  vim.api.nvim_buf_delete(state.bufh, { force = true })
  state.bufh = nil

  state.last_mode = nil

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
    neoterm.open(opts)
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
