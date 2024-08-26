return {
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
		},
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettier,
					require("none-ls.diagnostics.eslint_d")
				},
			})

			vim.keymap.set("n", "<leader>fp", "<cmd>Prettier<CR>")
		end,
		opts = function(_, opts)
			local nls = require("null-ls")
			opts.sources = opts.sources or {}

			table.insert(opts.sources, nls.builtins.formatting.prettier)
		end,
	},
	{
		"MunifTanjim/prettier.nvim",
		config = function()
			local prettier = require("prettier")

			prettier.setup({
				bin = "prettierd",
				filetypes = {
					"css",
					"html",
					"javascript",
					"javascriptreact",
					"json",
					"markdown",
					"scss",
					"typescript",
					"typescriptreact",
					"yaml",
				},
				cli_options = {
					arrow_parens = "avoid",
					bracket_spacing = true,
					embedded_language_formatting = "auto",
					html_whitespace_sensitivity = "css",
					jsx_single_quote = false,
					prose_wrap = "preserve",
					quote_props = "as-needed",
					semi = true,
					single_quote = true,
					tab_width = 4,
					trailingComma = "none",
				},
			})
		end,
	},
}
