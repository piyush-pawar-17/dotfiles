return {
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			{
				"folke/snacks.nvim",
				opts = {
					input = { enabled = false },
					picker = { enabled = false },
					terminal = {},
				},
			},
		},
		config = function()
			local keymap = require("utils.keymap")

			---@type opencode.Opts
			vim.g.opencode_opts = {}

			vim.o.autoread = true

			keymap.map({ "n", "x" }, "<C-a><C-w>", function()
				require("opencode").ask("@this: ", { submit = true })
			end, { desc = "Ask opencode" })
			keymap.map({ "n", "x" }, "<leader>os", function()
				require("opencode").select()
			end, { desc = "Execute opencode action…" })
			keymap.map({ "n", "x" }, "<C-a><C-a>", function()
				require("opencode").prompt("@this")
			end, { desc = "Add to opencode" })
			keymap.map({ "n", "t" }, "<C-a><C-t>", function()
				require("opencode").toggle()
			end, { desc = "Toggle opencode" })
			keymap.map("n", "<S-C-u>", function()
				require("opencode").command("session.half.page.up")
			end, { desc = "opencode half page up" })
			keymap.map("n", "<S-C-d>", function()
				require("opencode").command("session.half.page.down")
			end, { desc = "opencode half page down" })
		end,
	},
}
