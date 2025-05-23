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
				local map = require("utils.keymap").map

				local function git_map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					map(mode, l, r, opts)
				end

				-- Navigation
				git_map("n", "[h", gs.prev_hunk, { desc = "Go to [P]revious hunk" })
				git_map("n", "]h", gs.next_hunk, { desc = "Go to [N]ext hunk" })

				-- Actions
				git_map("n", "<leader>hr", gs.reset_hunk, { desc = "[H]unk [r]eset" })
				git_map("n", "<leader>bl", function()
					gs.blame_line({ full = true })
				end, { desc = "[B]lame [l]ine" })
				git_map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "[T]oggle [b]lame" })
				git_map("n", "<leader>hp", gs.preview_hunk, { desc = "[H]unk [P]review" })

				-- Telescope
				git_map("n", "<leader>gb", function()
					require("telescope.builtin").git_branches(require("telescope.themes").get_dropdown({
						previewer = false,
					}))
				end, { desc = "[G]it [b]ranches" })

				-- Text object
				git_map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "[I]n [h]unk" })
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
			local map = require("utils.keymap").map

			neogit.setup({
				kind = "floating",
				auto_close_console = false,
				mappings = {
					finder = {
						["<c-j>"] = "Next",
						["<c-k>"] = "Previous",
					},
				},
			})

			map("n", "<leader>gs", neogit.open, { silent = true, noremap = true, desc = "[G]it [S]tatus" })

			map("n", "<leader>gf", function()
				neogit.open({ "fetch" })
			end, { silent = true, noremap = true, desc = "[G]it [F]etch" })

			map("n", "<leader>gl", function()
				neogit.open({ "log" })
			end, { silent = true, noremap = true, desc = "[G]it [L]og" })

			map(
				{ "n", "v", "x" },
				"<leader>gh",
				":DiffviewFileHistory %<CR>",
				{ silent = true, noremap = true, desc = "[G]it [H]istory" }
			)

			map("n", "<leader>gd", ":DiffviewOpen<CR>", { silent = true, noremap = true, desc = "Open Diffview" })

			map("n", "<leader>gg", ":DiffviewClose<CR>", { silent = true, noremap = true, desc = "Close Diffview" })
		end,
	},
}
