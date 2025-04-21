return {
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- This function gets run when an LSP attaches to a particular buffer.
			-- That is to say, every time a new file is opened that is associated with
			-- an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			-- function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					local map = require("utils.keymap").map
					local lsp_map = function(keys, func, desc)
						map("n", keys, func, { buffer = event.buf, silent = true, desc = "LSP: " .. desc })
					end

					lsp_map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					lsp_map("gr", ":Glance references<CR>", "[G]oto [R]eferences")
					lsp_map("gt", ":Glance type_definitions<CR>", "[G]oto [T]ype Definitions")
					lsp_map("gi", ":Glance implementations<CR>", "[G]oto [I]mplementation")

					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					lsp_map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					lsp_map("<leader>fs", function()
						require("telescope.builtin").lsp_document_symbols(require("telescope.themes").get_dropdown())
					end, "[F]ind [S]ymbols")
					lsp_map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					lsp_map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					lsp_map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					lsp_map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					lsp_map("K", function()
						vim.lsp.buf.hover({ border = "single" })
					end, "Hover documentation")
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				ts_ls = {},
				cssls = {},
				cssmodules_ls = {},
				eslint = {},
				html = {},
				jsonls = {},
				marksman = {},
				mdx_analyzer = {},
				tailwindcss = {},
				prettierd = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				bashls = {},
				clangd = {},
				dockerls = {},
				gopls = {},
				sqls = {},
			}

			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			---@diagnostic disable-next-line: missing-fields
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = "󰌵 ",
					},
				},
			})
		end,
	},
	{
		"dnlhc/glance.nvim",
		config = function()
			local glance = require("glance")
			local actions = glance.actions

			---@diagnostic disable-next-line: missing-fields
			require("glance").setup({
				border = {
					enable = true, -- Show window borders. Only horizontal borders allowed
					top_char = "―",
					bottom_char = "―",
				},
				---@diagnostic disable-next-line: missing-fields
				mappings = {
					list = {
						["<Tab>"] = actions.open_fold,
						["<S-Tab>"] = actions.close_fold,
					},
				},
			})

			local colors = require("catppuccin.palettes").get_palette()
			local GlanceColors = {
				GlancePreviewNormal = { bg = colors.mantle },
				GlanceWinBarTitle = { bg = colors.mantle },
				GlanceWinBarFilename = { fg = colors.blue, bg = colors.mantle },
				GlanceWinBarFilepath = { fg = colors.overlay0, bg = colors.mantle },
				GlanceListNormal = { bg = colors.mantle },
				GlanceBorderTop = { fg = colors.lavender },
				GlancePreviewBorderBottom = { fg = colors.lavender },
				GlanceListBorderBottom = { fg = colors.lavender },
			}

			for hl, col in pairs(GlanceColors) do
				vim.api.nvim_set_hl(0, hl, col)
			end
		end,
	},
}
