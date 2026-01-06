-- snacks.nvim configuration
-- Disable animations and smooth scrolling globally

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			indent = {
				enabled = true,
				animate = {
					enabled = false,
				},
			},

			scroll = {
				enabled = false,
			},

			picker = {
				sources = {
					explorer = {
						hidden = true, -- 隠しファイル (.で始まる) を表示
						ignored = true, -- gitignore されたファイル (.env等) を表示
					},
				},
			},
		},
	},
}
