local M = {}

M.set_colors = function()
	local colors = require("catppuccin.palettes").get_palette()
	local TelescopeColor = {
		TelescopeMatching = { fg = colors.flamingo },
		TelescopeSelection = { fg = colors.text, bg = colors.base, bold = true },
		TelescopePromptPrefix = { bg = colors.mantle },
		TelescopePromptNormal = { bg = colors.mantle },
		TelescopeResultsNormal = { bg = colors.crust },
		TelescopePreviewNormal = { bg = colors.crust },
		TelescopePromptBorder = { bg = colors.mantle, fg = colors.mantle },
		TelescopeResultsBorder = { bg = colors.crust, fg = colors.crust },
		TelescopePreviewBorder = { bg = colors.crust, fg = colors.crust },
		TelescopePromptTitle = { bg = colors.pink, fg = colors.crust },
		TelescopeResultsTitle = { fg = colors.crust },
		TelescopePreviewTitle = { bg = colors.green, fg = colors.crust },
	}

	for hl, col in pairs(TelescopeColor) do
		vim.api.nvim_set_hl(0, hl, col)
	end
end

return M
