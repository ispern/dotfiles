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

	-- ブラウザでライブプレビュー（mermaid/KaTeX対応、GitHub風CSS）
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = ":call mkdp#util#install()",
		init = function()
			local css_path = vim.fn.stdpath("config") .. "/github-markdown.css"
			vim.g.mkdp_markdown_css = css_path
		end,
		config = function()
			vim.cmd([[do FileType]])
		end,
		keys = {
			{ "<leader>mp", ft = "markdown", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview (Browser)" },
		},
	},
}
