return {
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
				dockerfile = { "dockerfmt" },
				nginx = { "nginxfmt" },
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
	{ -- Linting
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufWritePost", "InsertLeave" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				dockerfile = { "hadolint" },
			}

			vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
				callback = function()
					if vim.bo.modifiable then
						lint.try_lint()
					end
				end,
			})

			-- Lint the buffer that triggered lazy-loading
			lint.try_lint()
		end,
	},
}
