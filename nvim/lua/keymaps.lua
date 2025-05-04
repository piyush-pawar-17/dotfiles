local map = require("utils.keymap").map

map("i", "jk", "<Esc>")

map("n", "x", '"_x')
map("n", "Y", "y$")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Stay in indent mode
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true })

map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>y", [["+y]])
map({ "n", "v" }, "<leader>d", [["_d]])

map("n", "<leader>hh", ":nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear [H]ighlight" })
map("n", "tw", ":Twilight<CR>", { noremap = false, silent = true })

--  Use CTRL+<hjkl> to switch between windows
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Resize with splits
map("n", "<M-'>", ":resize +3<CR>", { desc = "Resize Horizontal Split Down", silent = true })
map("n", "<M-;>", ":resize -3<CR>", { desc = "Resize Horizontal Split Up", silent = true })
map("n", "<M-,>", ":vertical resize -5<CR>", { desc = "Resize Vertical Split Down", silent = true })
map("n", "<M-.>", ":vertical resize +5<CR>", { desc = "Resize Vertical Split Up", silent = true })

-- Buffers
map("n", "<leader>l", ":b#<CR>", { desc = "[L]ast Buffer", noremap = false, silent = true })

-- Undotree
map("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
