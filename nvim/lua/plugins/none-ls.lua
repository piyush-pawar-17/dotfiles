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
					null_ls.builtins.formatting.goimports,
					null_ls.builtins.formatting.gofumpt,
					null_ls.builtins.formatting.golines,
					null_ls.builtins.formatting.sql_formatter,
				},
			})
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
			-- format_on_save = function(bufnr)
			-- 	-- Disable "format_on_save lsp_fallback" for languages that don't
			-- 	-- have a well standardized coding style. You can add additional
			-- 	-- languages here or re-enable it for the disabled ones.
			-- 	local disable_filetypes = { c = true, cpp = true }
			-- 	return {
			-- 		timeout_ms = 500,
			-- 		lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
			-- 	}
			-- end,
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
