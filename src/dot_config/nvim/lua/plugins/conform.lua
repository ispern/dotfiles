local js_formatters = { { "prettierd", "prettier", "biome" } }

return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			json = js_formatters,
			javascript = js_formatters,
			javascriptreact = js_formatters,
			typescript = js_formatters,
			typescriptreact = js_formatters,
			astro = js_formatters,
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
