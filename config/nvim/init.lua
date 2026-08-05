vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.winborder = "single"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.completeopt = "menu,menuone,noinsert,noselect"
vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

vim.pack.add({
		{src="https://github.com/nvim-lua/plenary.nvim"},
		{src="https://github.com/nvim-telescope/telescope.nvim"},
		{src="https://github.com/neovim/nvim-lspconfig"},
		{src="https://github.com/chomosuke/typst-preview.nvim"}
})
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method('textDocument/completion', ev.buf) then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    if vim.fn.complete_info().selected == -1 then
      return '<C-n><C-y>'  -- select first item, then confirm
    else
      return '<C-y>'       -- confirm whatever's highlighted
    end
  else
    return '<Tab>'
  end
end, { expr = true })

require "telescope".setup({})
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>f', builtin.find_files, {desc = 'Telescope find files'})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {desc = 'Telescope live grep'})
vim.keymap.set('n', '<leader>h', builtin.help_tags, {desc = 'Telescope help tags'})
vim.keymap.set('n', '<leader>b', builtin.buffers, {desc = 'Telescope buffers'})


vim.keymap.set('n', '<leader>cd', ":Ex<CR>")
vim.lsp.enable({"lua_ls", "tinymist"})
 
local theme_path = vim.fn.expand("~/.cache/nvim/theme.lua")
 
local function load_theme()
	if vim.fn.filereadable(theme_path) == 0 then
		return nil
	end
	local ok, theme = pcall(dofile, theme_path)
	if not ok or type(theme) ~= "table" then
		return nil
	end
	return theme
end
 
local function strip_alpha(hex)
	if hex and #hex == 9 then
		return "#" .. hex:sub(-6)
	end
	return hex
end
 
local function apply_theme()
	local theme = load_theme()
	if not theme then
		return
	end
 
	local bg_panel = strip_alpha(theme.bg_panel)
 
	vim.o.background = theme.is_light and "light" or "dark"
 
	local hl = vim.api.nvim_set_hl
	hl(0, "Normal", { bg = theme.bg, fg = theme.fg })
	hl(0, "NormalFloat", { bg = bg_panel, fg = theme.fg })
	hl(0, "FloatBorder", { fg = theme.accent2, bg = bg_panel })
	hl(0, "CursorLine", { bg = bg_panel })
	hl(0, "LineNr", { fg = theme.muted })
	hl(0, "CursorLineNr", { fg = theme.accent2 })
	hl(0, "Visual", { bg = theme.accent1, fg = theme.bg })
	hl(0, "Pmenu", { bg = bg_panel, fg = theme.fg })
	hl(0, "PmenuSel", { bg = theme.accent2, fg = theme.bg })
	hl(0, "Search", { bg = theme.accent4, fg = theme.bg })
	hl(0, "IncSearch", { bg = theme.accent5, fg = theme.bg })
	hl(0, "Comment", { fg = theme.muted, italic = true })
end
 
apply_theme()
 
 
local uv = vim.uv or vim.loop
local watcher = uv.new_fs_event()
if watcher then
	local function watch()
		watcher:start(theme_path, {}, vim.schedule_wrap(function()
			apply_theme()
			watcher:stop()
			watch()
		end))
	end
	watch()
end
