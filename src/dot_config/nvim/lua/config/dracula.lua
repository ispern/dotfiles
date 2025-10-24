local dracula = require("dracula")
local palette = require("colors.palette")

local info = palette.green
local hint = palette.yellow

dracula.setup({
  -- customize dracula color palette
  colors = palette,
  -- show the '~' characters after the end of buffers

  show_end_of_buffer = false, -- default false
  -- use transparent background
  transparent_bg = false, -- default false
  -- set custom lualine background color
  lualine_bg_color = "#44475a", -- default nil
  -- set italic comment
  italic_comment = true, -- default false
  -- overrides the default highlights see `:h synIDattr`

  overrides = {
    LspReferenceText = { fg = dracula.colors().fg, bg = dracula.colors().comment },
    LspReferenceWrite = { fg = dracula.colors().fg, bg = dracula.colors().comment },
    LspReferenceRead = { fg = dracula.colors().fg, bg = dracula.colors().comment },
    NormalFloat =  { fg = dracula.colors().fg, bg = palette.bgdarker },
    DiagnosticInfo = { fg = info, },
    DiagnosticHint = { fg = hint, },
    DiagnosticUnderlineInfo = { undercurl = true, sp = info, },
    DiagnosticUnderlineHint = { undercurl = true, sp = hint, },
    DiagnosticSignInfo = { fg = info, },
    DiagnosticSignHint = { fg = hint, },
    DiagnosticFloatingError = { fg = dracula.colors().fg, },
    DiagnosticFloatingWarn = { fg = dracula.colors().fg, },
    DiagnosticFloatingInfo = { fg = dracula.colors().fg, },
    DiagnosticFloatingHint = { fg = dracula.colors().fg, },
    DiagnosticVirtualTextInfo = { fg = info, },
    DiagnosticVirtualTextHint = { fg = hint, },
    LspDiagnosticsDefaultInformation = { fg = info, },
    LspDiagnosticsDefaultHint = { fg = hint, },
    -- Visual mode selection highlighting
    Visual = { fg = dracula.colors().fg, bg = palette.selection },
    VisualNOS = { fg = dracula.colors().fg, bg = palette.selection },
    -- Examples
    -- NonText = { fg = dracula.colors().white }, -- set NonText fg to white
    -- NvimTreeIndentMarker = { link = "NonText" }, -- link to NonText highlight
    -- Nothing = {} -- clear highlight of Nothing
  },
})

vim.cmd [[
  colorscheme dracula
]]

local api = vim.api
local colors = dracula.colors()

api.nvim_set_hl(0, 'LspDiagnosticsSignError', { link = 'DiagnosticDefaultError' })
api.nvim_set_hl(0, 'LspDiagnosticsSignHint', { link = 'DiagnosticDefaultHint' })

-- remove obsolete TS* highlight groups
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/b273a06728305c1e7bd0179977ca48049aeff5e6/lua/nvim-treesitter/highlight.lua
-- # Misc
api.nvim_set_hl(0, '@punctuation.special', { link = 'Special' })

-- # Constants
api.nvim_set_hl(0, '@constant.macro', { link = 'Macro' })
api.nvim_set_hl(0, '@string', { fg = colors.yellow })
api.nvim_set_hl(0, '@string.escape', { link = 'Character' })
api.nvim_set_hl(0, '@symbol', { fg = colors.purple })
api.nvim_set_hl(0, '@annotation', { fg = colors.yellow })
api.nvim_set_hl(0, '@attribute', { fg = colors.green, italic = true })

-- Functions
api.nvim_set_hl(0, '@function.builtin', { fg = colors.cyan })
api.nvim_set_hl(0, '@function.macro', { link = 'Function' })
api.nvim_set_hl(0, '@parameter', { fg = colors.orange, italic = true })
api.nvim_set_hl(0, '@parameter.reference', { fg = colors.orange })
api.nvim_set_hl(0, '@field', { fg = colors.orange })
api.nvim_set_hl(0, '@constructor', { fg = colors.cyan })

-- Keywords
api.nvim_set_hl(0, '@label', { fg = colors.purple, italic = true })

-- Variable
api.nvim_set_hl(0, '@variable.builtin', { fg = colors.purple, italic = true })

-- Text
api.nvim_set_hl(0, '@text', { fg = colors.fg })
api.nvim_set_hl(0, '@text.strong', { fg = colors.fg, bold = true })
api.nvim_set_hl(0, '@text.emphasis', { fg = colors.fg })
api.nvim_set_hl(0, '@text.underline', { underline = true })
api.nvim_set_hl(0, '@text.title', { fg = colors.yellow })
api.nvim_set_hl(0, '@text.literal', { fg = colors.yellow })
api.nvim_set_hl(0, '@text.uri', { fg = colors.yellow })

-- HTML and JSX tag attributes. By default, this group is linked to TSProperty,
-- which in turn links to Identifer (white).
api.nvim_set_hl(0, '@tag', { fg = colors.pink })
api.nvim_set_hl(0, '@tag.attribute', { fg = colors.green, italic = true })

