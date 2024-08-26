return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal" },
		},
		opts = {
			enable_git_status = true,
			filesystem = {
				filtered_items = {
					hide_by_name = { "node_modules" },
				},
				components = {
					name = function(config, node, state)
						local components = require("neo-tree.sources.common.components")

						local name = components.name(config, node, state)
						if node:get_depth() == 1 then
							name.text = vim.fs.basename(vim.loop.cwd() or "")
						end
						return name
					end,
				},
				window = {
					mappings = {
						["\\"] = "close_window",
					},
				},
			},
		},
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
					["<M-l>"] = "actions.select_vsplit",
				},
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
