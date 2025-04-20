return {
	{ "tpope/vim-sleuth" }, -- Detect tabstop and shiftwidth automatically
	{ "tpope/vim-surround" },
	{ "folke/twilight.nvim", opts = {} },
	{ "eandrju/cellular-automaton.nvim" },
	{ "mbbill/undotree" },
	{ "kevinhwang91/nvim-bqf", event = "VeryLazy", opts = {} },

	{
		"numToStr/Comment.nvim",
		lazy = false,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("Comment").setup({
				toggler = {
					line = "<leader>/",
					block = "<leader>?",
				},
				opleader = {
					line = "<leader>/",
					block = "<leader>?",
				},
			})
		end,
	},

	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = true },
		config = function()
			local todo_comments = require("todo-comments")

			vim.keymap.set("n", "]t", function()
				todo_comments.jump_next()
			end, { desc = "Next todo comment" })

			vim.keymap.set("n", "[t", function()
				todo_comments.jump_prev()
			end, { desc = "Previous todo comment" })

			vim.keymap.set("n", "<leader>tl", ":TodoTelescope<CR>", { desc = "Toggle todo list" })

			todo_comments.setup()
		end,
	},

	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({
				render = "virtual",
				virtual_symbol = "",
				virtual_symbol_prefix = "",
				virtual_symbol_position = "inline",
				enable_tailwind = true,
			})

			vim.keymap.set(
				"n",
				"tc",
				require("nvim-highlight-colors").toggle,
				{ silent = true, desc = "[T]oggle [C]olors" }
			)
		end,
	},

	{
		"stevearc/resession.nvim",
		config = function()
			local resession = require("resession")
			resession.setup({})

			-- Automatically save sessions on by working directory on exit
			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					resession.save(vim.fn.getcwd(), { notify = true })
				end,
			})

			-- Automatically load sessions on startup by working directory
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					-- Only load the session if nvim was started with no args
					if vim.fn.argc(-1) == 0 then
						resession.load(vim.fn.getcwd(), { silence_errors = true })
					end
				end,
				nested = true,
			})
		end,
	},

	{
		"laytan/cloak.nvim",
		config = function()
			require("cloak").setup({
				enabled = true,
				cloak_character = "*",
				highlight_group = "Comment",
				patterns = {
					{
						file_pattern = {
							".env*",
						},
						cloak_pattern = "=.+",
					},
				},
			})
		end,
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				char = {
					enabled = false,
				},
			},
		},
		keys = {
			{
				"<leader>sl",
				mode = { "n", "x", "o" },
				function()
					---@diagnostic disable-next-line: missing-fields
					require("flash").jump({
						search = { mode = "search", max_length = 0 },
						label = { after = { 0, 0 } },
						pattern = "^",
					})
				end,
			},
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					---@diagnostic disable-next-line: missing-fields
					require("flash").jump({
						search = {
							mode = function(str)
								return "\\<" .. str
							end,
						},
					})
				end,
				desc = "Flash",
			},
			{
				"<leader>sb",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			indent = {
				enabled = true,
				only_scope = true,
				only_current = true,
				scope = {
					only_current = true,
				},
				blank = {
					char = "·",
				},
			},
			dashboard = {
				enabled = true,
				sections = {
					{ section = "header" },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
			scratch = {
				ft = "markdown",
			},
		},
		keys = {
			{
				"<leader>.",
				function()
					require("snacks").scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					require("snacks").scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
		},
	},

	{
		"echasnovski/mini.splitjoin",
		config = function()
			local miniSplitJoin = require("mini.splitjoin")

			miniSplitJoin.setup({
				mappings = { toggle = "" }, -- Disable default mapping
			})
			vim.keymap.set({ "n", "x" }, "<leader>sj", function()
				miniSplitJoin.join()
			end, { desc = "Join arguments" })
			vim.keymap.set({ "n", "x" }, "<leader>sk", function()
				miniSplitJoin.split()
			end, { desc = "Split arguments" })
		end,
	},
}
