return {
	{
		"ThePrimeagen/harpoon",
		config = function()
			require("harpoon").setup({})

			local mark = require("harpoon.mark")
			local ui = require("harpoon.ui")

			vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "[A]dd file to harpoon" })
			vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Harpoon quick toggle" })
			vim.keymap.set("n", "<leader>m", ":Telescope harpoon marks<CR>", { desc = "Harpoon [m]arks" })

			vim.keymap.set("n", "<leader>1", function()
				ui.nav_file(1)
			end)
			vim.keymap.set("n", "<leader>2", function()
				ui.nav_file(2)
			end)
			vim.keymap.set("n", "<leader>3", function()
				ui.nav_file(3)
			end)
			vim.keymap.set("n", "<leader>4", function()
				ui.nav_file(4)
			end)
			vim.keymap.set("n", "<leader>5", function()
				ui.nav_file(5)
			end)
		end,
	},
}
