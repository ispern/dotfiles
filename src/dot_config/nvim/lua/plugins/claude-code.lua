return {
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {
			snacks_win_opts = {
				keys = {
					-- ターミナルモードでCtrl+w でNORMALモードに戻る
					["<C-w>"] = {
						function()
							vim.cmd("stopinsert")
						end,
						mode = "t",
						desc = "Exit terminal mode",
					},
					-- ターミナルモードでペイン移動
					["<C-h>"] = { "<C-\\><C-n><C-w>h", mode = "t", desc = "Move to left pane" },
					["<C-j>"] = { "<C-\\><C-n><C-w>j", mode = "t", desc = "Move to below pane" },
					["<C-k>"] = { "<C-\\><C-n><C-w>k", mode = "t", desc = "Move to above pane" },
					["<C-l>"] = { "<C-\\><C-n><C-w>l", mode = "t", desc = "Move to right pane" },
				},
			},
		},
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>aC", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			-- { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			-- { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			-- { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
			},
			-- Diff management
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	},
}
