return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,preview,noselect" },
				mapping = cmp.mapping.preset.insert({
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),
					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-a>"] = cmp.mapping.confirm({ select = true }),
					-- Manually trigger a completion from nvim-cmp.
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				window = {
					completion = {
						border = "single",
					},
					documentation = {
						border = "single",
					},
				},
			})

			-- `/` cmdline setup.
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- `:` cmdline setup.
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})
		end,
	},
}
