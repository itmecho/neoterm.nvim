local state = {
    winh = nil,
    bufh = nil,
    chan = nil,
    last_command = nil
}

local config = {
    mode = "vertical",
    noinsert = false
}

-- Returns a bool to show if the neoterm window exists
local function win_is_open()
    return state.winh ~= nil and vim.api.nvim_win_is_valid(state.winh) == true
end

-- returns a bool to show if the buf exists
local function buf_is_valid()
    return state.bufh ~= nil and vim.api.nvim_buf_is_valid(state.bufh) == true
end

local neoterm = {}

-- Sets global configuration
-- Options:
--	mode - set how the terminal window will be displayed
--		* vertical
--		* horizonal
--		* fullscreen
--	noinsert - don't enter insert mode when switching to the neoterm window
function neoterm.setup(opts)
    config.mode = opts.mode or config.mode
    config.noinsert = opts.noinsert or config.noinsert
end

-- Opens the terminal window. If it was opened previously, the same terminal buffer will be used
-- Options:
--	mode - override the global config mode
--	noinsert - don't enter insert mode after switching to the neoterm window
function neoterm.open(opts)
    opts = opts or {}

    local buf_created = false
    if buf_is_valid() == false then
        state.bufh = vim.api.nvim_create_buf(true, true)
        buf_created = true
    end

    if win_is_open() ~= true then
        local ui = vim.api.nvim_list_uis()[1]

        local mode = opts.mode or config.mode

        local winopts = {
            relative = "editor",
            width = math.floor(ui.width / 2),
            height = ui.height - vim.o.cmdheight - 3,
            row = 0,
            col = ui.width,
            style = "minimal",
            border = "single"
        }
        if mode == "horizontal" then
            winopts.width = ui.width
            winopts.height = math.floor((ui.height - vim.o.cmdheight - 2) / 3)
            winopts.row = (2 * winopts.height)
            winopts.col = 1
        elseif mode == "fullscreen" then
            winopts.width = ui.width
            winopts.col = 1
        end

        state.winh = vim.api.nvim_open_win(state.bufh, true, winopts)

        if buf_created then
            vim.cmd [[term]]
            state.chan = vim.b.terminal_job_id
        end
    end

    local noinsert = config.noinsert
    if opts.noinsert ~= nil then
        noinsert = opts.noinsert
    end

    if noinsert == false then
        vim.cmd [[startinsert]]
    end
    vim.api.nvim_buf_set_name(state.bufh, "neoterm")
end

function neoterm.close()
    vim.api.nvim_win_close(state.winh, false)
    state.winh = nil
end

function neoterm.toggle()
    if win_is_open() then
        neoterm.close()
    else
        neoterm.open()
    end
end

function neoterm.exit()
    neoterm.close()

    vim.api.nvim_chan_send(state.chan, "exit\n")
    state.chan = nil

    vim.api.nvim_buf_delete(state.bufh, {force = true})
    state.bufh = nil
end

-- Takes a command as a string and runs it in the neoterm buffer. If the window is closed, it will be toggled
function neoterm.run(command)
    if win_is_open() == false or state.chan == nil then
        neoterm.open()
    end

    if state.last_command ~= nil then
        -- Send <C-c> to make sure any on-going commands like log tails are stopped before running the new command
        vim.api.nvim_chan_send(state.chan, "\003")
    end
    state.last_command = command
    vim.api.nvim_chan_send(state.chan, command .. "\n")
end

function neoterm.rerun()
    if state.last_command == nil then
        print("Last command empty")
    end
    neoterm.run(state.last_command)
end

return neoterm
