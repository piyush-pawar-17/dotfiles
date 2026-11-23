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

						-- snacks.picker (ported from the old Telescope colours)
						SnacksPickerMatch = { fg = colors.flamingo },
						SnacksPickerListCursorLine = { fg = colors.text, bg = colors.base, bold = true },
						SnacksPickerPrompt = { fg = colors.pink, bg = colors.mantle },
						SnacksPickerInput = { bg = colors.mantle },
						SnacksPickerInputBorder = { fg = colors.mantle, bg = colors.mantle },
						SnacksPickerListBorder = { fg = colors.surface1, bg = colors.crust },
						SnacksPickerBox = { bg = colors.crust },
						SnacksPickerBoxBorder = { fg = colors.pink, bg = colors.crust },
						SnacksPickerBoxTitle = { fg = colors.crust, bg = colors.pink },
						SnacksPickerList = { bg = colors.crust },
						SnacksPickerPreview = { bg = colors.crust },
						SnacksPickerPreviewBorder = { fg = colors.pink, bg = colors.crust },
						SnacksPickerPreviewTitle = { fg = colors.crust, bg = colors.green },
						SnacksPickerDir = { link = "Comment" },
					}
				end,
			})

			vim.cmd.colorscheme("catppuccin")
			-- Configure highlights
			vim.cmd.hi("Comment gui=none")
		end,
	},
}
