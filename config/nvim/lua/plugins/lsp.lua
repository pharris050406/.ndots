return {
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig", -- Acts as a background database for configs in v0.11+
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- 1. Configure the Autocomplete Engine Menu
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                })
            })

            -- 2. Pass completion capabilities globally to all native configs
            vim.lsp.config('*', { capabilities = capabilities })

            -- 3. Enable the servers (Default configurations are sourced automatically)
            vim.lsp.enable('clangd')
            vim.lsp.enable('bashls')
            vim.lsp.enable('nixd')
            vim.lsp.enable('lua_ls')
            vim.lsp.enable('texlab')
	    vim.lsp.enable('julials')
            -- 4. Global Keybinds (Only active when LSP attaches)
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local opts = {buff = args.buff} 
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                end,
            })
        end
    }
}
