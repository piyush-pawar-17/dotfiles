return {
	{
		"MunifTanjim/prettier.nvim",
		config = function()
			local prettier = require("prettier")

			prettier.setup({
				bin = "prettier",
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
				},
				cli_options = {
					arrow_parens = "always",
					bracket_spacing = true,
					embedded_language_formatting = "auto",
					html_whitespace_sensitivity = "css",
					jsx_single_quote = false,
					prose_wrap = "preserve",
					quote_props = "as-needed",
					semi = true,
					single_quote = true,
					tab_width = 4,
					use_tabs = false,
					trailing_comma = "none",
				},
			})
		end,
	},
	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>fd",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat [D]ocument",
			},
		},
		opts = {
			notify_on_error = false,
			formatters_by_ft = {
				lua = { "stylua" },
				typescript = { "prettier", "prettierd", stop_after_first = true },
				typescriptreact = { "prettier", "prettierd", stop_after_first = true },
				javascript = { "prettier", "prettierd", stop_after_first = true },
				javascriptreact = { "prettier", "prettierd", stop_after_first = true },
				json = { "prettier", "prettierd", stop_after_first = true },
				html = { "prettier", "prettierd", stop_after_first = true },
				css = { "prettier", "prettierd", stop_after_first = true },
				go = { "goimports", "gofumpt", "golines" },
				sql = { "pg_format" },
				markdown = { "prettier", "prettierd", stop_after_first = true },
			},
			formatters = {
				pg_format = {
					command = "pg_format",
					args = {
						"-s",
						"4", -- 4 spaces indentation
						"-u",
						"2", -- Uppercase keywords
						"-U",
						"2", -- Uppercase types
						"-",
					},
					stdin = true,
				},
			},
		},
	},
}
