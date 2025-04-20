local M = {}

--- @param mode string|string[]
--- @param keys string
--- @param action string|function
--- @param opts? vim.keymap.set.Opts
M.map = function(mode, keys, action, opts)
	vim.keymap.set(mode, keys, action, opts)
end

return M
