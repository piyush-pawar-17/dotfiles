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
				custom_highlights = function(colors)
					return {
						Keyword = { fg = colors.maroon },
						Special = { fg = colors.maroon },
						Include = { fg = colors.blue },
						["@variable.member"] = { fg = colors.text },
						["@property"] = { fg = colors.text },
						["@tag"] = { fg = colors.blue },
						["@tag.attribute"] = { fg = colors.yellow },
						["@tag.attribute.tsx"] = { fg = colors.yellow },
						["@keyword.return"] = { fg = colors.red },
					}
				end,
			})

			vim.cmd.colorscheme("catppuccin")
			-- Configure highlights
			vim.cmd.hi("Comment gui=none")
		end,
	},
}
