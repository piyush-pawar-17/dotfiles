return {
	{ "tpope/vim-sleuth" }, -- Detect tabstop and shiftwidth automatically
	{ "tpope/vim-surround" },

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
		"folke/twilight.nvim",
		opts = {},
	},

	{ "eandrju/cellular-automaton.nvim" },
	{ "mbbill/undotree" },

	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({
				render = "virtual",
				virtual_symbol = "■",
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
}
