return {
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
				disabled_filetypes = { "neo-tree", "alpha", "oil" },
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
}
