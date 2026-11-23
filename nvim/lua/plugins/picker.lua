-- Fuzzy picker: snacks.picker (snacks.nvim itself is set up in misc.lua; lazy.nvim merges both specs)

local exclude = { "node_modules", "dist", "package-lock.json", "pnpm-lock.yaml", "yarn.lock" }

-- Open the selected file and list its LSP symbols, to jump straight to a symbol while searching
local function symbols_for_selected(picker, item)
	if not item or not item.file then
		return
	end
	local path = Snacks.picker.util.path(item)
	picker:close()

	vim.schedule(function()
		vim.cmd.edit(vim.fn.fnameescape(path))
		local buf = vim.api.nvim_get_current_buf()
		if #vim.lsp.get_clients({ bufnr = buf }) > 0 then
			Snacks.picker.lsp_symbols()
			return
		end
		vim.api.nvim_create_autocmd("LspAttach", {
			buffer = buf,
			once = true,
			callback = function()
				vim.schedule(Snacks.picker.lsp_symbols)
			end,
		})
	end)
end

local function harpoon_marks()
	local items = {}
	for idx, mark in ipairs(require("harpoon").get_mark_config().marks) do
		if mark.filename and mark.filename ~= "" then
			items[#items + 1] = {
				idx = idx,
				text = mark.filename,
				file = mark.filename,
				pos = { math.max(mark.row or 1, 1), mark.col or 0 },
			}
		end
	end
	Snacks.picker.pick({ title = "Harpoon", items = items, format = "file" })
end

local function pick(source, opts)
	return function()
		Snacks.picker[source](opts)
	end
end

return {
	{
		"folke/snacks.nvim",
		opts = function(_, opts)
			opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
				enabled = true,
				ui_select = true, -- replaces telescope-ui-select
				layout = {
					cycle = true,
					preset = function()
						return vim.o.columns >= 120 and "prompt_top" or "vertical"
					end,
				},
				layouts = {
					-- Telescope-style: prompt on top, results under it, preview on the right
					prompt_top = {
						layout = {
							box = "horizontal",
							width = 0.8,
							min_width = 120,
							height = 0.8,
							border = "none",
							{
								box = "vertical",
								border = "single",
								title = "{title} {live} {flags}",
								-- Border drawn in the input bg colour, so it acts as padding
								{ win = "input", height = 1, border = "single" },
								-- Top border acts as a thin separator under the input
								{ win = "list", border = "top" },
							},
							{ win = "preview", title = "{preview}", border = "single", width = 0.5 },
						},
					},
				},
				formatters = {
					file = { filename_first = true },
				},
				sources = {
					files = { hidden = true, exclude = exclude },
					grep = { hidden = true, exclude = exclude },
					grep_word = { hidden = true, exclude = exclude },
					buffers = {
						win = {
							input = { keys = { ["<C-d>"] = { "bufdelete", mode = { "n", "i" } } } },
						},
					},
				},
				actions = {
					symbols_for_selected = symbols_for_selected,
					trouble_open = function(picker)
						require("trouble.sources.snacks").actions.trouble_open.action(picker)
					end,
					trouble_add = function(picker)
						require("trouble.sources.snacks").actions.trouble_add.action(picker)
					end,
				},
				win = {
					input = {
						keys = {
							["<C-a>"] = { "symbols_for_selected", mode = { "n", "i" } },
							["<C-t>"] = { "trouble_open", mode = { "n", "i" } },
							["<C-e>"] = { "trouble_add", mode = { "n", "i" } },
						},
					},
				},
			})
		end,
		keys = {
			{ "<leader>ff", pick("files"), desc = "[F]ind [F]iles" },
			-- Filter by glob after `--`, e.g. `foo -- -g=*.lua`
			{ "<leader>fg", pick("grep"), desc = "[F]ind by [G]rep" },
			{ "<leader>sw", pick("grep_word"), mode = { "n", "x" }, desc = "[S]earch current [W]ord" },
			{ "<leader>sd", pick("diagnostics"), desc = "[S]earch [D]iagnostics" },
			{ "<leader>sr", pick("resume"), desc = "[S]earch [R]esume" },
			{ "<leader><leader>", pick("buffers"), desc = "[ ] Find existing buffers" },
			{ "<leader>gb", pick("git_branches", { layout = "select" }), desc = "[G]it [b]ranches" },
			{ "<leader>tl", pick("todo_comments"), desc = "Toggle todo list" },
			{ "<leader>hm", harpoon_marks, desc = "[H]arpoon [m]arks" },
		},
	},
}
