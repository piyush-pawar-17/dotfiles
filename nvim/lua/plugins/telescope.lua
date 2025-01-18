return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
			"scottmckendry/telescope-resession.nvim",
		},
		config = function()
			local function document_symbols_for_selected(prompt_bufnr)
				local action_state = require("telescope.actions.state")
				local actions = require("telescope.actions")
				local entry = action_state.get_selected_entry()

				if entry == nil then
					print("No file selected")
					return
				end

				actions.close(prompt_bufnr)

				vim.schedule(function()
					local bufnr = vim.fn.bufadd(entry.path)
					vim.fn.bufload(bufnr)

					local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

					vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, result, _, _)
						if err then
							print("Error getting document symbols: " .. vim.inspect(err))
							return
						end

						if not result or vim.tbl_isempty(result) then
							print("No symbols found")
							return
						end

						local function flatten_symbols(symbols, parent_name)
							local flattened = {}

							for _, symbol in ipairs(symbols) do
								local name = symbol.name

								if parent_name then
									name = parent_name .. "." .. name
								end

								table.insert(flattened, {
									name = name,
									kind = symbol.kind,
									range = symbol.range,
									selectionRange = symbol.selectionRange,
								})

								if symbol.children then
									local children = flatten_symbols(symbol.children, name)
									for _, child in ipairs(children) do
										table.insert(flattened, child)
									end
								end
							end
							return flattened
						end

						local flat_symbols = flatten_symbols(result)

						-- Define highlight group for symbol kind
						vim.cmd([[highlight TelescopeSymbolKind guifg=#61AFEF]])

						require("telescope.pickers")
							.new({}, {
								prompt_title = "Document Symbols: " .. vim.fn.fnamemodify(entry.path, ":t"),
								finder = require("telescope.finders").new_table({
									results = flat_symbols,
									entry_maker = function(symbol)
										local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Other"
										return {
											value = symbol,
											display = function(entry)
												local display_text = string.format("%-50s %s", entry.value.name, kind)
												return display_text,
													{
														{
															{ #entry.value.name + 1, #display_text },
															"TelescopeSymbolKind",
														},
													}
											end,
											ordinal = symbol.name,
											filename = entry.path,
											lnum = symbol.selectionRange.start.line + 1,
											col = symbol.selectionRange.start.character + 1,
										}
									end,
								}),
								sorter = require("telescope.config").values.generic_sorter({}),
								previewer = require("telescope.config").values.qflist_previewer({}),
								attach_mappings = function(_, map)
									map("i", "<CR>", function(prompt_bufnr)
										local selection = action_state.get_selected_entry()
										actions.close(prompt_bufnr)
										vim.cmd("edit " .. selection.filename)
										vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
									end)
									return true
								end,
							})
							:find()
					end)
				end)
			end

			require("telescope").setup({
				defaults = {
					file_ignore_patterns = {
						"node_modules",
						"dist",
						"package%-lock.json",
						"pnpm%-lock.yaml",
						"yarn.lock",
					},
					mappings = {
						n = {
							["<C-d>"] = require("telescope.actions").delete_buffer,
							["<C-a>"] = document_symbols_for_selected,
						},
						i = {
							["<C-d>"] = require("telescope.actions").delete_buffer,
							["<C-j>"] = {
								require("telescope.actions").move_selection_next,
								type = "action",
								opts = { nowait = true, silent = true },
							},
							["<C-k>"] = {
								require("telescope.actions").move_selection_previous,
								type = "action",
								opts = { nowait = true, silent = true },
							},
							["<C-a>"] = document_symbols_for_selected,
							["<C-n>"] = false,
							["<C-p>"] = false,
						},
					},
				},
				-- pickers = {},
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					},
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
					resession = {
						prompt_title = "Find Sessions",
						dir = "session",
						path_substitutions = {
							{ find = os.getenv("HOME"), replace = "~" },
						},
					},
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension, "noice")
			pcall(require("telescope").load_extension, "harpoon")

			local builtin = require("telescope.builtin")
			local utils = require("telescope.utils")

			local find_files = function()
				local _, ret, _ = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
				if ret == 0 then
					builtin.git_files({ hidden = true, recurse_submodules = true })
				else
					builtin.find_files({ hidden = true })
				end
			end

			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>ff", find_files, { desc = "[F]ind [F]iles" })
			vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "[S]earch Select [T]elescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>fg", require("plugins.telescope.multi-ripgrep"), { desc = "[F]ind by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

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
		end,
	},
}
