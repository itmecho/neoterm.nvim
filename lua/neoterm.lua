local winh = nil
local bufh = nil
local chan = nil
local last_command = nil

-- Returns a bool to show if the neoterm window exists
local function win_is_open()
    return winh ~= nil and vim.api.nvim_win_is_valid(winh)
end

-- returns a bool to show if the buf exists
local function buf_is_valid()
    return bufh ~= nil and vim.api.nvim_buf_is_valid(bufh)
end

-- Creates the neoterm window and return the user to the window where the call was made
local function create_window()
    local curr = vim.api.nvim_get_current_win()
    vim.cmd("vsplit")
    winh = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(curr)
end

-- Creates the neoterm buffer and starts the terminal
local function create_buffer()
    local curr = vim.api.nvim_get_current_win()
    bufh = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(winh, bufh)
    vim.api.nvim_set_current_win(winh)
    vim.cmd("term")
    vim.cmd("norm G")
    vim.api.nvim_buf_set_name(bufh, "neoterm")
    chan = vim.b.terminal_job_id
    vim.api.nvim_set_current_win(curr)
end

local M = {}

-- Toggles the neoterm window.
--
-- If the window doesn't exist it is created. If it already exists, it is closed
-- If the buffer doesn't exist is is created and set as the active buffer in the neoterm window
-- If either the window of buffer were created, the window buffer is set to the neoterm buffer
M.toggle = function()
    local link_buf = false
    if win_is_open() then
        vim.api.nvim_win_close(winh, true)
        winh = nil
    else
        create_window()
        link_buf = true
    end
    if buf_is_valid() == false then
        create_buffer()
        link_buf = true
    end

    if link_buf then
        vim.api.nvim_win_set_buf(winh, bufh)
    end
end

-- Closes the window and deletes the buffer. This entirely resets the term state
M.exit = function()
    if win_is_open() then
        vim.api.nvim_win_close(winh, true)
        winh = nil
    end
    if buf_is_valid() then
        vim.api.nvim_buf_delete(bufh, {force = true})
        bufh = nil
    end
    chan = nil
end

-- Takes a command as a string and runs it in the neoterm buffer. If the window is closed, it will be toggled
M.run = function(cmd)
    if win_is_open() == false or chan == nil then
        M.toggle()
    end

    if last_command ~= nil then
        -- Send <C-c> to make sure any on-going commands like log tails are stopped before running the new command
        vim.api.nvim_chan_send(chan, "\003")
    end
    last_command = cmd
    vim.api.nvim_chan_send(chan, cmd .. "\n")
end

-- Runs the last command again
M.rerun = function()
    if last_command == nil then
        print("Last command empty")
    end
    M.run(last_command)
end

-- Jumps to the neoterm window and enters insert mode. If called from the neoterm window, it will jump back to the
-- previous window
M.interactive = function()
    if win_is_open() == false then
        M.toggle()
    end

    if vim.api.nvim_get_current_win() == winh then
        vim.cmd("wincmd w")
    else
        vim.api.nvim_set_current_win(winh)
        vim.cmd("startinsert")
    end
end

return M
