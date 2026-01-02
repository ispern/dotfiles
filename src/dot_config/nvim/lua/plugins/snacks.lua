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
		},
	},
}
