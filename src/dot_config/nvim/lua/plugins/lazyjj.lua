-- lazyjj.nvim プラグイン設定
-- lazyjj（jj用のlazygit風TUI）をNeovimに統合
-- Jujutsu操作のためのフローティングウィンドウインターフェースを提供

return {
	{
		"swaits/lazyjj.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "LazyJJ" },
		keys = {
			{ "<leader>jj", "<cmd>LazyJJ<cr>", desc = "LazyJJ: Open lazyjj" },
		},
		opts = {},
	},
}
