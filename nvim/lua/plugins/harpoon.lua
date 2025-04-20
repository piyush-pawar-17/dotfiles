return {
	{
		"ThePrimeagen/harpoon",
		config = function()
			require("harpoon").setup({})

			local mark = require("harpoon.mark")
			local ui = require("harpoon.ui")
			local map = require("utils.keymap").map

			map("n", "<leader>a", mark.add_file, { desc = "[A]dd file to harpoon" })
			map("n", "<C-e>", ui.toggle_quick_menu, { desc = "Harpoon quick toggle" })
			map("n", "<leader>hm", ":Telescope harpoon marks<CR>", { desc = "[H]arpoon [m]arks" })

			map("n", "<leader>1", function()
				ui.nav_file(1)
			end)
			map("n", "<leader>2", function()
				ui.nav_file(2)
			end)
			map("n", "<leader>3", function()
				ui.nav_file(3)
			end)
			map("n", "<leader>4", function()
				ui.nav_file(4)
			end)
			map("n", "<leader>5", function()
				ui.nav_file(5)
			end)
		end,
	},
}
