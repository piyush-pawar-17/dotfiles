return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			local map = require("utils.keymap").map

			harpoon:setup()

			map("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "[A]dd file to harpoon" })
			map("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon quick toggle" })

			for i = 1, 5 do
				map("n", "<leader>" .. i, function()
					harpoon:list():select(i)
				end, { desc = "Harpoon file " .. i })
			end
		end,
	},
}
