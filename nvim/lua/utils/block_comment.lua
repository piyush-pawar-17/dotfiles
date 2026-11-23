-- Block comments (`/* ... */`, `{/* ... */}`, `<!-- ... -->`) for the `gb` operator.
-- Neovim's built-in `gc` only does line comments; this toggles one block comment
-- around a motion, a visual selection, or the current line.

local M = {}

-- Left and right parts of the block commentstring for the language under the cursor
local function block_parts()
	local candidates = { vim.bo.commentstring }
	local ok, comments = pcall(require, "ts-comments.comments")
	if ok then
		candidates = comments.resolve(vim.bo.filetype) -- treesitter-aware, so JSX gets {/* */}
	end

	for _, cs in ipairs(candidates) do
		local left, right = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
		if left and right and right ~= "" then
			return left, right
		end
	end

	if vim.bo.filetype == "lua" then
		return "--[[", "]]"
	end
	-- Languages with `//` line comments use `/* */` for blocks
	if (candidates[1] or ""):match("^%s*//") then
		return "/*", "*/"
	end
end

-- Range of the block comment containing (row, col), found with treesitter.
-- Returns rows 1-based and cols 0-based inclusive, like `toggle`.
local function enclosing_block(row, col, left, right)
	local ok, node = pcall(vim.treesitter.get_node, { pos = { row - 1, col }, ignore_injections = false })
	while ok and node do
		if node:type():find("comment") then
			-- Check the parent too: JSX wraps the comment node in `{ }`
			for _, n in ipairs({ node, node:parent() }) do
				local text = vim.treesitter.get_node_text(n, 0)
				if vim.startswith(text, left) and vim.endswith(text, right) then
					local sr, sc, er, ec = n:range()
					return sr + 1, sc, er + 1, ec - 1
				end
			end
		end
		node = node:parent()
	end
end

-- Toggle a block comment from (srow, scol) to (erow, ecol): rows 1-based, cols 0-based inclusive
local function toggle(srow, scol, erow, ecol)
	local left, right = block_parts()
	if not left then
		vim.notify("No block comment style for '" .. vim.bo.filetype .. "'", vim.log.levels.WARN)
		return
	end

	-- Inside an existing block comment: target the whole comment so it gets removed
	local bsr, bsc, ber, bec = enclosing_block(srow, scol, left, right)
	if bsr then
		srow, scol, erow, ecol = bsr, bsc, ber, bec
	end

	local first = vim.api.nvim_buf_get_lines(0, srow - 1, srow, false)[1]
	local last = vim.api.nvim_buf_get_lines(0, erow - 1, erow, false)[1]
	ecol = math.min(ecol, #last - 1)

	local start_text = first:sub(scol + 1)
	local end_text = last:sub(1, ecol + 1)
	local _, left_end = start_text:find("^" .. vim.pesc(left) .. " ?")
	local right_start = end_text:find(" ?" .. vim.pesc(right) .. "$")

	-- Edit the end first so the start position stays valid
	if left_end and right_start and (srow ~= erow or right_start > left_end) then
		vim.api.nvim_buf_set_text(0, erow - 1, right_start - 1, erow - 1, ecol + 1, {})
		vim.api.nvim_buf_set_text(0, srow - 1, scol, srow - 1, scol + left_end, {})
	else
		vim.api.nvim_buf_set_text(0, erow - 1, ecol + 1, erow - 1, ecol + 1, { " " .. right })
		vim.api.nvim_buf_set_text(0, srow - 1, scol, srow - 1, scol, { left .. " " })
	end
end

-- Whole lines: comment from the first non-blank character to the last one
local function toggle_lines(srow, erow)
	local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
	while #lines > 0 and not lines[1]:find("%S") do
		table.remove(lines, 1)
		srow = srow + 1
	end
	while #lines > 0 and not lines[#lines]:find("%S") do
		table.remove(lines)
		erow = erow - 1
	end
	if #lines == 0 then
		return
	end

	local scol = lines[1]:find("%S") - 1
	local ecol = #lines[#lines]:match("^(.-)%s*$") - 1
	toggle(srow, scol, erow, ecol)
end

--- Operator for `g@`: call with no argument from an expr mapping to start it
---@param motion? "char"|"line"|"block"
function M.operator(motion)
	if motion == nil then
		vim.o.operatorfunc = "v:lua.require'utils.block_comment'.operator"
		return "g@"
	end

	local s = vim.api.nvim_buf_get_mark(0, "[")
	local e = vim.api.nvim_buf_get_mark(0, "]")
	if motion == "char" then
		toggle(s[1], s[2], e[1], e[2])
	else
		toggle_lines(s[1], e[1])
	end
end

return M
