return {
	{
		"OXY2DEV/markview.nvim",
		lazy = false, -- Recommended
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("markview").setup({})

			vim.keymap.set(
				"n",
				"<leader>mp",
				":Markview toggle<CR>",
				{ silent = true, noremap = true, desc = "[M]arkview [p]review toggle" }
			)
			vim.keymap.set(
				"n",
				"<leader>ms",
				":Markview splitToggle<CR>",
				{ silent = true, noremap = true, desc = "[M]arkview [s]plit toggle" }
			)
		end,
	},
}
