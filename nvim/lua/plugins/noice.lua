return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {},
		enabled = true,
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
		},
		config = function()
			local noice = require("noice")

			noice.setup({
				cmdline = {
					enabled = false,
					view = "cmdline_popup",
					opts = {},
					format = {
						cmdline = { pattern = "^:", icon = "", lang = "vim" },
						search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
						search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
						filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
						lua = {
							pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
							icon = "",
							lang = "lua",
						},
						help = { pattern = "^:%s*he?l?p?%s+", icon = "?" },
						input = { view = "cmdline_input", icon = " " },
					},
				},
				lsp = {
					progress = { enabled = true },
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
				},
				messages = { enabled = false },
				popupmenu = { enabled = true },
				signature = { enabled = true },
				notify = { enabled = false },
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = false, -- use a classic bottom cmdline for search
					command_palette = false, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
				views = {
					cmdline_popup = {
						border = {
							style = "single",
						},
					},
					hover = {
						position = { row = 2, col = 2 },
						border = {
							style = "single",
						},
					},
					confirm = {
						border = {
							style = "single",
						},
					},
					popup = {
						border = {
							style = "single",
						},
					},
				},
			})

			vim.diagnostic.config({
				virtual_text = {
					prefix = "",
					spacing = 4,
				},
				underline = true,
			})
		end,
	},
}
