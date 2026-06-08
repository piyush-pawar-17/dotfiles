return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local function search_result()
				if vim.v.hlsearch == 0 then
					return ""
				end
				local last_search = vim.fn.getreg("/")
				if not last_search or last_search == "" then
					return ""
				end
				local searchcount = vim.fn.searchcount({ maxcount = 9999 })
				return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
			end

			require("lualine").setup({
				options = {
					theme = "catppuccin",
					section_separators = { left = "", right = "" },
					component_separators = { left = "/", right = "\\" },
					disabled_filetypes = { "alpha", "oil" },
				},
				sections = {
					lualine_a = {
						{
							"mode",
							fmt = function(mode)
								return " " .. mode
							end,
						},
					},
					lualine_b = {
						{
							"branch",
							icon = { "󰘬" },
							"|",
						},
						"diff",
					},
					lualine_c = {
						{
							"filename",
							file_status = true,
							path = 1,
							symbols = {
								readonly = "",
								modified = " ",
							},
						},
					},
					lualine_x = {
						{
							"diagnostics",
							symbols = {
								error = " ",
								warn = " ",
								hint = "󰌵 ",
								info = " ",
							},
						},
					},
					lualine_y = { search_result },
					lualine_z = {},
				},
			})
		end,
	},

	{
		"nanozuki/tabby.nvim",
		config = function()
			local mocha = require("catppuccin.palettes").get_palette("mocha")
			local theme = {
				fill = "TabLineFill",
				current_tab = { fg = mocha.base, bg = mocha.blue },
				tab = { fg = mocha.overlay1, bg = mocha.mantle },
				line_sep = { fg = mocha.blue, bg = mocha.mantle },
			}

			require("tabby.tabline").set(function(line)
				return {
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab

						local left_sep
						if tab.is_current() then
							left_sep = line.sep("▎", theme.line_sep, theme.current_tab)
						else
							left_sep = line.sep("▎", theme.fill, theme.fill)
						end

						return {
							left_sep,
							tab.number(),
							tab.name(),
							line.sep(" ", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					hl = theme.fill,
				}
			end)
		end,
	},
}
