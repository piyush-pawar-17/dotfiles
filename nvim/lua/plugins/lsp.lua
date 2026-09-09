return {
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"b0o/schemastore.nvim",
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

					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
					lsp_map("<leader>gt", ":Glance type_definitions<CR>", "[G]oto [T]ype Definitions")
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
					lsp_map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					lsp_map("<leader>k", vim.diagnostic.open_float, "Open Diagnostics")
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
				biome = {},
				html = {},
				jsonls = {
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				},
				yamlls = {
					settings = {
						yaml = {
							schemaStore = {
								enable = false,
								url = "",
							},
							schemas = require("schemastore").yaml.schemas(),
						},
					},
				},
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

			for server_name, server in pairs(servers) do
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				vim.lsp.config(server_name, server)
			end

			require("mason-lspconfig").setup({ automatic_enable = false })
			vim.lsp.enable(vim.tbl_keys(servers))

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
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "simple",
				options = {
					show_source = {
						enabled = true,
					},
					use_icons_from_diagnostic = true,
				},
			})
			vim.diagnostic.config({ virtual_text = false })
		end,
	},
	{
		"rachartier/tiny-code-action.nvim",
		dependencies = {
			-- optional picker via telescope
			{ "nvim-telescope/telescope.nvim" },
		},
		event = "LspAttach",
		opts = {},
		config = function()
			local tiny_code_action = require("tiny-code-action")
			tiny_code_action.setup({})

			vim.keymap.set({ "n", "x" }, "<leader>ca", function()
				tiny_code_action.code_action({})
			end, { noremap = true, silent = true })
		end,
	},
}
