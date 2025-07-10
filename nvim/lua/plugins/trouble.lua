return {
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>XX",
				":Trouble diagnostics toggle focus=true<CR>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<CR>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle focus=true<CR>",
				desc = "Quickfix List (Trouble)",
			},
			{
				"<leader>xt",
				"<cmd>Trouble telescope toggle focus=true<CR>",
				desc = "Telescope List (Trouble)",
			},
			{
				"<leader>xs",
				"<cmd>Trouble lsp_document_symbols toggle focus=true win.position=right<CR>",
				desc = "Document Symbols (Trouble)",
			},
		},
	},
}
