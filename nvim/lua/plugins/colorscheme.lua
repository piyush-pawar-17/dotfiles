return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				no_italic = true,
				transparent_background = true,
			})
			vim.cmd.colorscheme("catppuccin")
			-- Configure highlights
			vim.cmd.hi("Comment gui=none")
		end,
	},
}
