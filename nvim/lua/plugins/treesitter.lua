return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- Install parsers (no-op if already installed, async)
			require("nvim-treesitter").install({
				"bash",
				"c",
				"css",
				"csv",
				"diff",
				"dockerfile",
				"go",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"scss",
				"sql",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			})

			-- Highlighting is provided by Neovim core
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		config = function()
			local map = require("utils.keymap").map
			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			require("nvim-treesitter-textobjects").setup({
				select = {
					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,
					selection_modes = {
						["@function.outer"] = "v",
						["@conditional.outer"] = "v",
					},
					include_surrounding_whitespace = true,
				},
				move = {
					set_jumps = true, -- whether to set jumps in the jumplist
				},
			})

			map({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end, { desc = "Select outer function" })
			map({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end, { desc = "Select inner function" })
			map({ "x", "o" }, "ac", function()
				select.select_textobject("@conditional.outer", "textobjects")
			end, { desc = "Select outer conditional" })
			map({ "x", "o" }, "ic", function()
				select.select_textobject("@conditional.inner", "textobjects")
			end, { desc = "Select inner conditional" })
			map("n", "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			map("n", "]F", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			map("n", "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Previous function start" })
			map("n", "[F", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Previous function end" })
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-ts-autotag").setup({})
		end,
		lazy = true,
		event = "VeryLazy",
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("nvim-autopairs").setup({})

			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")

			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
