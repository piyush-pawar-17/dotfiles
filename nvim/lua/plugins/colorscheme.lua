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
						["@tag.builtin.tsx"] = { fg = colors.blue },
						["@tag"] = { fg = colors.blue },
						["@tag.attribute.tsx"] = { fg = colors.peach },
						["@tag.attribute"] = { fg = colors.peach },
						["@tag.tsx"] = { fg = colors.yellow },
						["@tag.delimiter"] = { fg = colors.overlay2 },
						["@markup.heading"] = { fg = colors.text },
					}
				end,
			})

			vim.cmd.colorscheme("catppuccin")
			-- Configure highlights
			vim.cmd.hi("Comment gui=none")
		end,
	},
}
