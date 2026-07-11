return{
    {
	-- helps with ssh tunneling and copying text to clipboard
	'ojroques/vim-oscyank',
    },
    {
	'tpope/vim-fugitive',
    },
    {
	'brenoprata10/nvim-highlight-colors',
	    config = function()
		require('nvim-highlight-colors').setup({})
	    end
    },
}
