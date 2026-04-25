-- IME auto-switch: switch to English when entering Normal mode
return {
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    config = function()
      require("im_select").setup({
        default_im_select = "com.justsystems.inputmethod.atok35.Roman",
        default_command = "macism",
        set_default_events = { "InsertLeave", "CmdlineLeave" },
        set_previous_events = { "InsertEnter" },
        async_switch_im = true,
      })
    end,
  },
}
