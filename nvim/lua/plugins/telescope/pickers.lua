local entry_maker = require("telescope.make_entry").gen_from_lsp_symbols({})
local entry_display = require("telescope.pickers.entry_display")

local M = {}

local icons = {
	Method = " ",
	Function = " ",
	Constructor = " ",
	Field = " ",
	Variable = " ",
	Class = " ",
	Interface = " ",
	Module = " ",
	Property = " ",
	Value = " ",
	Enum = " ",
	Color = " ",
	EnumMember = " ",
	Constant = " ",
	Struct = " ",
}

local function format_entry(entry)
	local icon = icons[entry.symbol_type] or " "
	local hl_group = "CmpItemKind" .. (entry.symbol_type or "")
	local dot_idx = entry.symbol_name:reverse():find("%.") or entry.symbol_name:reverse():find("::")

	local symbol, qualifier

	if dot_idx == nil then
		symbol = entry.symbol_name
		qualifier = entry.filename
	else
		symbol = entry.symbol_name:sub(1 - dot_idx)
		qualifier = entry.symbol_name:sub(1, #entry.symbol_name - #symbol - 1)
	end

	-- Replace cwd with ""
	qualifier = string.sub(qualifier, #vim.fn.getcwd() + 1)
	local symbol_type = (entry.symbol_type or "symbol"):lower()
	icon = icon .. symbol_type

	return icon, hl_group, symbol, qualifier
end

local displayer = entry_display.create({
	separator = " ",
	items = {
		{ width = 13 },
		{ remaining = true },
	},
})

M.lsp_dynamic_workspace_symbols_entry_maker = function(line)
	local originalEntryTable = entry_maker(line)

	originalEntryTable.display = function(entry)
		local icon, hl_group, symbol, qualifier = format_entry(entry)

		return displayer({
			{ icon, hl_group },
			string.format("%s\t\tin %s", symbol, qualifier),
		})
	end

	return originalEntryTable
end

M.lsp_document_symbols_entry_maker = function(line)
	local originalEntryTable = entry_maker(line)

	originalEntryTable.display = function(entry)
		local icon, hl_group, symbol = format_entry(entry)

		return displayer({
			{ icon, hl_group },
			symbol,
		})
	end

	return originalEntryTable
end

return M
