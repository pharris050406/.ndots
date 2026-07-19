return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    init = function()
        -- CRITICAL: In the new version, you must manually tell Neovim 
        -- to activate tree-sitter highlighting when a file loads.
        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
    config = function()
        -- The new plugin uses a direct install function call 
        -- instead of an 'ensure_installed' array in a setup block.
        require('nvim-treesitter').install({
            "lua",
            "nix",
            "qml",
            "ron",
	    "cpp",
	    "c",
	    "julia"
        })
    end
}
