vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "Y", "y$")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("i", "jk", "<Esc>")

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true })

vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "<leader>hh", ":nohlsearch<CR>", { desc = "Clear [H]ighlight" })
vim.keymap.set("n", "tw", ":Twilight<CR>", { noremap = false, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Resize with splits
vim.keymap.set("n", "<M-k>", ":resize +3<CR>", { desc = "Resize Horizontal Split Down", silent = true })
vim.keymap.set("n", "<M-j>", ":resize -3<CR>", { desc = "Resize Horizontal Split Up", silent = true })
vim.keymap.set("n", "<M-h>", ":vertical resize -5<CR>", { desc = "Resize Vertical Split Down", silent = true })
vim.keymap.set("n", "<M-l>", ":vertical resize +5<CR>", { desc = "Resize Vertical Split Up", silent = true })

-- Buffers
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer", noremap = false, silent = true })
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next Buffer", noremap = false, silent = true })
vim.keymap.set("n", "<leader>l", ":b#<CR>", { desc = "[L]ast Buffer", noremap = false, silent = true })

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
