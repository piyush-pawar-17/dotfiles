local M = {}

M.set_colors = function()
	local colors = require("catppuccin.palettes").get_palette()
	local TelescopeColor = {
		TelescopeMatching = { fg = colors.flamingo },
		TelescopeSelection = { fg = colors.text, bg = colors.base, bold = true },
		TelescopePromptPrefix = { bg = colors.base },
		TelescopePromptNormal = { bg = colors.base },
		TelescopeResultsNormal = { bg = colors.mantle },
		TelescopePreviewNormal = { bg = colors.mantle },
		TelescopePromptBorder = { bg = colors.base, fg = colors.base },
		TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
		TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
		TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
		TelescopeResultsTitle = { fg = colors.mantle },
		TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
	}

	for hl, col in pairs(TelescopeColor) do
		vim.api.nvim_set_hl(0, hl, col)
	end
end

return M
