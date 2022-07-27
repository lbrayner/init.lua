local api = vim.api

-- Requires Neovim 0.7.0+
if not api["nvim_create_autocmd"] then
    return
end

local keymap = require("lbrayner.keymap")
local nnoremap = keymap.nnoremap

local function get_cursor()
    return api.nvim_win_get_cursor(0)
end

local function open_float()
    -- Save the current cursor position
    local line_col = get_cursor()
    -- Move the cursor to the second column
    api.nvim_win_set_cursor(0,{ line_col[1], 1 })
    local prev_pos = vim.diagnostic.get_prev_pos()
    -- If there's an anterior diagnostic in the current line, it's in column 1
    if prev_pos and prev_pos[1]+1 == line_col[1] and prev_pos[2] < get_cursor()[2] then
        -- Go to column 1 and open the floating window
        api.nvim_win_set_cursor(0,{ line_col[1], 0 })
        -- Scheduling lest CursorMoved is triggered
        return vim.schedule(vim.diagnostic.open_float)
    end
    -- Move the cursor to the beginning of the line
    api.nvim_win_set_cursor(0,{ line_col[1], 0 })
    local next_pos = vim.diagnostic.get_next_pos()
    -- If there's no next diagnostic in the current line, there might be one in
    -- column 1
    if not next_pos or next_pos[1]+1 ~= line_col[1] then
        -- If there isn't, restore the cursor
        return vim.diagnostic.open_float() or api.nvim_win_set_cursor(0, line_col)
    end
    -- Move the cursor to the first diagnostic in the line
    api.nvim_win_set_cursor(0, { line_col[1], next_pos[2] })
    -- Scheduling lest CursorMoved is triggered
    return vim.schedule(vim.diagnostic.open_float)
end

local opts = { silent=true }

nnoremap("<space>e", open_float, opts)
nnoremap("<space>E", function()
    vim.diagnostic.open_float { scope="buffer" }
end, opts)
nnoremap("[d", vim.diagnostic.goto_prev, opts)
nnoremap("]d", vim.diagnostic.goto_next, opts)

api.nvim_create_user_command("DiagnosticSetLocationList",
    vim.diagnostic.setloclist, { nargs=0 })
api.nvim_create_user_command("QuickFixAllDiagnostics",
    vim.diagnostic.setqflist, { nargs=0 })

local err = "DiagnosticSignError"
local war = "DiagnosticSignWarn"
local inf = "DiagnosticSignInfo"
local hin = "DiagnosticSignHint"

local function DefaultDiagnostics()
    api.nvim_command("highlight DiagnosticError ctermfg=1 guifg=Red")
    api.nvim_command("highlight DiagnosticWarn  ctermfg=3 guifg=Orange")
    api.nvim_command("highlight DiagnosticInfo  ctermfg=4 guifg=LightBlue")
    api.nvim_command("highlight DiagnosticHint  ctermfg=7 guifg=LightGrey")

    vim.fn.sign_define(err, { text="E", texthl=err, linehl="", numhl="" })
    vim.fn.sign_define(war, { text="W", texthl=war, linehl="", numhl="" })
    vim.fn.sign_define(inf, { text="I", texthl=inf, linehl="", numhl="" })
    vim.fn.sign_define(hin, { text="H", texthl=hin, linehl="", numhl="" })

    vim.diagnostic.config({ virtual_text=true })
end

api.nvim_create_user_command("DefaultDiagnostics", DefaultDiagnostics, { nargs=0 })

-- For virtual text
local spacing = 2 -- Even if you set spacing to 0, there are 2 extra spaces
local prefix = "•"
local padding = spacing + string.len(prefix) + 2 -- prefix sandwich

local function CustomDiagnostics()
    vim.fn.sign_define(err, { text="Ɛ", texthl=err, linehl="", numhl="" })
    vim.fn.sign_define(war, { text="Ɯ", texthl=war, linehl="", numhl="" })
    vim.fn.sign_define(inf, { text="Ɩ", texthl=inf, linehl="", numhl="" })
    vim.fn.sign_define(hin, { text="ƕ", texthl=hin, linehl="", numhl="" })

    vim.diagnostic.config({ virtual_text={
        format=function(diagnostic)
            local lnum = diagnostic.lnum
            local line = api.nvim_buf_get_lines(0, lnum, lnum+1, true)[1]
            local line_len = string.len(line)
            local winwidth = api.nvim_win_get_width(0) - 2 - 3 -- sign & column number
            local message = diagnostic.message
            local mess_len = string.len(message)
            if line_len + padding + mess_len > winwidth then
                return ""
            end
            return string.format(" %s %s", prefix, message)
        end,
        prefix="",
        spacing=0,
    } })
end

api.nvim_create_user_command("CustomDiagnostics", CustomDiagnostics, { nargs=0 })

local augroup = api.nvim_create_augroup("custom_diagnostics", { clear=true })
api.nvim_create_autocmd({ "VimEnter" }, {
    group = augroup,
    callback = CustomDiagnostics,
})
