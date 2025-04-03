return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			current_line_blame = true,
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Go to [P]revious hunk" })
				map("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Go to [N]ext hunk" })

				-- Actions
				map("n", "<leader>hr", gs.reset_hunk, { desc = "[H]unk [r]eset" })
				map("n", "<leader>bl", function()
					gs.blame_line({ full = true })
				end, { desc = "[B]lame [l]ine" })
				map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "[T]oggle [b]lame" })
				map("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "[H]unk [P]review" })

				-- Telescope
				map("n", "<leader>gb", function()
					require("telescope.builtin").git_branches(require("telescope.themes").get_dropdown({
						previewer = false,
					}))
				end, { desc = "[G]it [b]ranches" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "[I]n [h]unk" })
			end,
		},
	},
	{
		"NeogitOrg/neogit",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			local neogit = require("neogit")
			neogit.setup({})

			vim.keymap.set("n", "<leader>gs", function()
				neogit.open({ kind = "floating" })
			end, { silent = true, noremap = true, desc = "[G]it [S]tatus" })

			vim.keymap.set("n", "<leader>gf", function()
				neogit.open({ "fetch" })
			end, { silent = true, noremap = true, desc = "[G]it [F]etch" })

			vim.keymap.set("n", "<leader>gl", function()
				neogit.open({ "log" })
			end, { silent = true, noremap = true, desc = "[G]it [L]og" })

			vim.keymap.set(
				{ "n", "v", "x" },
				"<leader>gh",
				":DiffviewFileHistory %<CR>",
				{ silent = true, noremap = true, desc = "[G]it [H]istory" }
			)

			vim.keymap.set(
				"n",
				"<leader>gd",
				":DiffviewOpen<CR>",
				{ silent = true, noremap = true, desc = "Open Diffview" }
			)

			vim.keymap.set(
				"n",
				"<leader>gg",
				":DiffviewClose<CR>",
				{ silent = true, noremap = true, desc = "Close Diffview" }
			)
		end,
	},
}
