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

			local map = require("utils.keymap").map

			map(
				"n",
				"<leader>mp",
				":Markview toggle<CR>",
				{ silent = true, noremap = true, desc = "[M]arkview [p]review toggle" }
			)
			map(
				"n",
				"<leader>ms",
				":Markview splitToggle<CR>",
				{ silent = true, noremap = true, desc = "[M]arkview [s]plit toggle" }
			)
		end,
	},
}
