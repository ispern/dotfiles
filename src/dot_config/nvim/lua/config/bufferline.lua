local map = vim.api.nvim_set_keymap

local bufferline = require('bufferline')
local palette = require('colors.palette')

local bar_bg = palette.bgdarker
local bar_fg = palette.fg
local elem_bg = palette.black
local elem_fg = palette.selection
local selected_bg = palette.bg
local selected_fg = palette.fg
local error_fg = palette.bright_pink
local warning_fg = palette.bright_yellow
local info_fg = palette.bright_purple
local pick_fg = palette.bright_cyan

local colors = {
  bar = { fg = bar_fg, bg = bar_bg },
  elem = { fg = elem_fg, bg = elem_bg },
  elem_inactive = { fg = elem_fg, bg = elem_bg },
  elem_selected = { fg = selected_fg, bg = selected_bg },
  separator = { fg = bar_bg, bg = elem_bg },
  separator_selected = { fg = bar_bg, bg = bar_bg },
  error = { fg = error_fg, bg = elem_bg, sp = error_fg },
  error_selected = { fg = error_fg, bg = selected_bg },
  warning = { fg = warning_fg, bg = elem_bg, sp = warning_fg },
  warning_selected = { fg = warning_fg, bg = selected_bg },
  info = { fg = info_fg, bg = elem_bg, sp = info_fg },
  info_selected = { fg = info_fg, bg = selected_bg },

  pick = { fg = pick_fg, bg = elem_bg },
  pick_selected = { fg = pick_fg, bg = selected_bg },
}

local diagnostics_signs = {
  ['error'] = '',
  warning = '',
  default = '',
}

local highlights
if vim.g.colors_name ~= 'dracula' then
  highlights = nil
else
  highlights = {
    background = colors.elem_inactive,
    buffer_selected = colors.elem_selected,
    buffer_visible = colors.elem_inactive,
    close_button = colors.elem,

    close_button_selected = colors.elem_selected,
    close_button_visible = colors.elem,
    diagnostic = colors.info,
    diagnostic_selected = colors.info_selected,
    diagnostic_visible = colors.info,

    duplicate = colors.elem,
    duplicate_selected = colors.elem_selected,
    duplicate_visible = colors.elem,
    error = colors.error,
    error_diagnostic = colors.error,
    error_diagnostic_selected = colors.error_selected,
    error_selected = colors.error_selected,
    fill = colors.bar,
    hint = colors.info,
    hint_diagnostic = colors.info,
    hint_diagnostic_selected = colors.info_selected,
    hint_diagnostic_visible = colors.info,
    hint_selected = colors.info_selected,
    hint_visible = colors.info,
    info = colors.info,
    info_diagnostic = colors.info,
    info_diagnostic_selected = colors.info_selected,
    info_diagnostic_visible = colors.info,
    info_selected = colors.info_selected,
    info_visible = colors.info,
    modified = colors.elem,
    modified_selected = colors.elem_selected,
    modified_visible = colors.elem,
    pick = colors.pick,

    pick_selected = colors.pick_selected,
    separator = colors.separator,
    separator_selected = colors.separator_selected,
    separator_visible = colors.separator,
    tab = colors.elem,

    tab_close = colors.bar,
    tab_selected = colors.elem_selected,
    warning = colors.warning,
    warning_diagnostic = colors.warning,

    warning_diagnostic_selected = colors.warning_selected,

    warning_diagnostic_visible = colors.warning,
    warning_selected = colors.warning_selected,
    warning_visible = colors.warning,
  }
end

bufferline.setup {
  options = {
    always_show_bufferline = false,
    diagnostics = 'nvim_lsp',
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = ' '
      for e, n in pairs(diagnostics_dict) do
        local sym = diagnostics_signs[e] or diagnostics_signs.default

        s = s .. (#s > 1 and ' ' or '') .. sym .. ' ' .. n
      end
      return s
    end,
    separator_style = 'thick',
    offsets = {
      {
        filetype = "neo-tree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left"
      }
    }
  },
}


local opts = { silent = true, nowait = true, noremap = true }
map('n', 'gb', '<cmd>BufferLinePick<cr>', opts)
map('n', '<leader>d', '<cmd>bdelete!<cr>', opts)
