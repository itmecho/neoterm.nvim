local winh = nil
local bufh = nil
local chan = nil
local last_command = nil

local function create_window()
    vim.cmd("vsplit")
    winh = vim.api.nvim_get_current_win()
end

local function create_buffer()
    bufh = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(winh, bufh)
    vim.api.nvim_set_current_win(winh)
    vim.cmd("term")
    vim.cmd("norm G")
    vim.api.nvim_buf_set_name(bufh, "vterm")
    chan = vim.b.terminal_job_id
end

local function toggle()
    local curr = vim.api.nvim_get_current_win()
    local link_buf = false
    if winh ~= nil and vim.api.nvim_win_is_valid(winh) then
        vim.api.nvim_win_close(winh, true)
    else
        create_window()
        link_buf = true
    end
    if bufh == nil or vim.api.nvim_buf_is_valid(bufh) == false then
        create_buffer()
        link_buf = true
    end

    if link_buf then
        vim.api.nvim_win_set_buf(winh, bufh)
    end

    vim.api.nvim_set_current_win(curr)
end

-- Closes the window and deletes the buffer. This entirely resets the term state
local function close()
    if winh ~= nil and vim.api.nvim_win_is_valid(winh) then
        vim.api.nvim_win_close(winh, true)
        winh = nil
    end
    if bufh ~= nil and vim.api.nvim_buf_is_valid(bufh) then
        vim.api.nvim_buf_delete(bufh, {force = true})
        bufh = nil
    end
    chan = nil
end

local function run(cmd)
    if vim.api.nvim_win_is_valid(winh) == false or chan == nil then
        toggle()
    end

    if last_command ~= nil then
        -- Send <C-c> to make sure any on-going commands like log tails are stopped before running the new command
        vim.api.nvim_chan_send(chan, "\003")
    end
    last_command = cmd
    vim.api.nvim_chan_send(chan, cmd .. "\n")
end

-- Runs the last command again
local function rerun()
    if last_command == nil then
        print("Last command empty")
    end
    run(last_command)
end

local function go_to_terminal()
    vim.api.nvim_set_current_win(winh)
    vim.cmd("startinsert")
end

return {
    toggle = toggle,
    close = close,
    run = run,
    rerun = rerun,
    go_to_terminal = go_to_terminal
}
