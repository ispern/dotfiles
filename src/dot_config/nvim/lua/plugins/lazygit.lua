-- lazygit.nvim プラグイン設定
-- lazygitのターミナルUIをNeovimに統合
-- Git操作のためのフローティングウィンドウインターフェースを提供

return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- オプション: コマンド実行時に遅延読み込み
		-- 既存のGitキーマップとの競合を避けるため、<leader>glプレフィックスを使用:
		-- - <leader>gb: Git blame
		-- - <leader>go: Git browse
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit: Open lazygit" },
			{ "<leader>gl", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit: Current file" },
			{ "<leader>gL", "<cmd>LazyGitFilter<cr>", desc = "LazyGit: Filter" },
			{ "<leader>glF", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit: Filter current file" },
		},
		config = function()
			-- オプション: lazygitウィンドウの外観をカスタマイズ
			-- プラグインはデフォルトでフローティングウィンドウを使用
			vim.g.lazygit_floating_window_winblend = 0 -- 透明度 (0-100)
			vim.g.lazygit_floating_window_scaling_factor = 0.9 -- ウィンドウサイズ (0.1-1.0)
			vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" } -- ボーダー文字
			vim.g.lazygit_floating_window_use_plenary = 0 -- plenary.nvimを使用 (0 or 1)
			vim.g.lazygit_use_neovim_remote = 1 -- neovim-remoteを使用 (0 or 1, 推奨: 1)
			vim.g.lazygit_use_custom_config_file_path = 0 -- カスタム設定ファイルを使用 (0 or 1)
			-- vim.g.lazygit_config_file_path = "" -- カスタムlazygit設定ファイルのパス

			-- オプション: lazygitプロセスをカスタマイズ
			-- vim.g.lazygit_use_neovim_remote = 1 -- より良い統合のために推奨
		end,
	},
}
