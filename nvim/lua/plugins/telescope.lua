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
			local builtin = require("telescope.builtin")
			local utils = require("telescope.utils")

			local multi_ripgrep = require("plugins.telescope.multi-ripgrep")
			local mappings = require("plugins.telescope.mappings")
			local formatters = require("plugins.telescope.formatters")
			local pickers = require("plugins.telescope.pickers")
			local colors = require("plugins.telescope.colors")

			require("telescope").setup({
				defaults = {
					layout_config = {
						horizontal = {
							preview_width = 0.5,
						},
					},
					file_ignore_patterns = {
						"node_modules",
						"dist",
						"package%-lock.json",
						"pnpm%-lock.yaml",
						"yarn.lock",
					},
					path_display = formatters.filename_first,
					mappings = {
						n = {
							["<C-d>"] = require("telescope.actions").delete_buffer,
							["<C-a>"] = mappings.document_symbols_for_selected,
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
							["<C-a>"] = mappings.document_symbols_for_selected,
							["<C-n>"] = false,
							["<C-p>"] = false,
						},
					},
				},
				pickers = {
					lsp_dynamic_workspace_symbols = {
						entry_maker = pickers.lsp_dynamic_workspace_symbols_entry_maker,
					},
					lsp_document_symbols = {
						entry_maker = pickers.lsp_document_symbols_entry_maker,
					},
				},
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

			colors.set_colors()

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension, "noice")
			pcall(require("telescope").load_extension, "harpoon")

			local find_files = function()
				local _, ret, _ = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
				if ret == 0 then
					builtin.git_files({ hidden = true, recurse_submodules = true })
				else
					builtin.find_files({ hidden = true })
				end
			end

			-- Keymaps
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>ff", find_files, { desc = "[F]ind [F]iles" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>fg", multi_ripgrep, { desc = "[F]ind by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
		end,
	},
}
