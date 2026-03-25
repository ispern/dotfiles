return {
	-- バッファ内でmarkdownをリッチ表示（見出し装飾、チェックボックス、テーブル整形等）
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "Avante" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.icons",
		},
		opts = {
			heading = {
				enabled = true,
				icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
			},
			code = {
				enabled = true,
				sign = false,
				width = "full",
			},
			checkbox = {
				enabled = true,
			},
			pipe_table = {
				enabled = true,
				style = "full",
			},
		},
	},

	-- ブラウザでライブプレビュー（mermaid/KaTeX対応）
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = ":call mkdp#util#install()",
		keys = {
			{ "<leader>mp", ft = "markdown", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview (Browser)" },
		},
	},
}
