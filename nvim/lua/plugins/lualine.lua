return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local function get_filetype()
			local devicons = require("nvim-web-devicons")

			local filetype = vim.bo.filetype
			-- Don't show anything if there is no filetype
			if filetype == "" then
				return ""
			end
			filetype = devicons.get_icon(vim.fn.expand("%:t"), nil, { default = true }) .. " " .. filetype

			return string.format("%s", filetype)
		end

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
