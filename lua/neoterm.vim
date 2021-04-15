local winh = nil
local bufh = nil
local chan = nil
local last_command = nil
local prev_winh = nil

local function win_is_open()
    return winh ~= nil and vim.api.nvim_win_is_valid(winh)
end

local function buf_is_valid()
    return bufh ~= nil and vim.api.nvim_buf_is_valid(bufh)
end

local function create_window()
    local curr = vim.api.nvim_get_current_win()
    vim.cmd("vsplit")
    winh = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(curr)
end

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

local function toggle()
    local link_buf = false
    if win_is_open() then
        vim.api.nvim_win_close(winh, true)
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
local function exit()
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

local function run(cmd)
    if win_is_open() == false or chan == nil then
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

local function interactive()
    if win_is_open() == false then
        toggle()
    end

    if vim.api.nvim_get_current_win() == winh then
        -- we're in the neoterm window
        if prev_winh == nil then
            print("Can't jump back to previous window")
        else
            local esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true)
            vim.api.nvim_feedkeys(esc, "i", true)
            vim.api.nvim_set_current_win(prev_winh)
        end
    else
        prev_winh = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(winh)
        vim.cmd("startinsert")
    end
end

return {
    toggle = toggle,
    interactive = interactive,
    exit = exit,
    run = run,
    rerun = rerun
}
