local winh = nil
local bufh = nil
local chan = nil
local last_command = nil

local function create_window()
    if vim.g.vterm_split == "horizontal" then
        vim.cmd("split")
    else
        vim.cmd("vsplit")
    end
    winh = vim.api.nvim_get_current_win()
end

local function create_buffer()
    bufh = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(winh, bufh)
    vim.api.nvim_set_current_win(winh)
    vim.cmd("term")
    for _, c in ipairs(vim.api.nvim_list_chans()) do
        if c.buffer == bufh then
            chan = c
        end
    end
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

local function send_command(cmd)
    if vim.api.nvim_win_is_valid(winh) == false or chan == nil then
        toggle()
    end
    last_command = cmd
    vim.api.nvim_chan_send(chan.id, cmd .. "\n")
end

local function rerun_command()
    send_command(last_command)
end

return {
    toggle = toggle,
    close = close,
    send_command = send_command,
    rerun_command = rerun_command
}
