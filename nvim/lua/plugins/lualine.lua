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

		require("lualine").setup({
			options = {
				theme = "catppuccin",
				section_separators = "",
				component_separators = "",
				disabled_filetypes = { "neo-tree", "alpha", "oil" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 1,
					},
				},
				lualine_x = { "diagnostics" },
				lualine_y = { get_filetype },
				lualine_z = { "location" },
			},
		})
	end,
}
