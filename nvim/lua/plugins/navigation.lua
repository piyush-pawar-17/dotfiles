return {
	{
		"echasnovski/mini.files",
		config = function()
			require("mini.files").setup({
				options = {
					permanent_delete = false,
					use_as_default_explorer = false,
				},
				mappings = {
					close = "\\",
				},
			})

			vim.keymap.set("n", "\\", ":lua MiniFiles.open()<CR>", { desc = "Open Mini Files" })
		end,
	},

	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				default_file_explorer = true,
				columns = { "icon" },
				keymaps = {
					["<C-h>"] = false,
					["<C-l>"] = false,
					["<C-k>"] = false,
					["<C-j>"] = false,
					["<C-c>"] = false,
					["q"] = "actions.close",
				},
				skip_confirm_for_simple_edits = true,
				delete_to_trash = true,
				view_options = {
					natural_order = true,
					show_hidden = true,
					is_always_hidden = function(name, _)
						return name == ".git"
					end,
				},
				float = {
					padding = 2,
					max_width = 120,
					max_height = 0,
				},
				win_options = {
					wrap = true,
					winblend = 0,
				},
			})

			-- Open parent directory in current window
			vim.keymap.set("n", "-", ":Oil<CR>", { silent = true, desc = "Open parent directory" })

			-- Open parent directory in floating window
			vim.keymap.set("n", "<space>-", require("oil").toggle_float)
		end,
	},
}
