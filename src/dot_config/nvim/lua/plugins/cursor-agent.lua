-- cursor-agent.nvim plugin configuration
-- Integrates Cursor CLI for AI-powered coding assistance
-- Configured to display in the right panel

return {
  {
    "xTacobaco/cursor-agent.nvim",
    cmd = { "CursorAgent", "CursorAgentSelection", "CursorAgentBuffer" },
    keys = {
      { "<leader>ca", "<cmd>CursorAgent<cr>", desc = "Cursor Agent: Toggle terminal" },
      { "<leader>cA", "<cmd>CursorAgentBuffer<cr>", desc = "Cursor Agent: Send buffer" },
      { "<leader>ca", "<cmd>CursorAgentSelection<cr>", desc = "Cursor Agent: Send selection", mode = "v" },
    },
    config = function()
      local cursor_agent = require("cursor-agent")
      local termui = require("cursor-agent.ui.term")
      
      -- Helper function to resolve size (from termui implementation)
      local function resolve_size(value, total)
        if type(value) == "number" then
          if value > 0 and value < 1 then
            return math.floor(total * value)
          end
          return math.floor(value)
        end
        return math.floor(total * 0.6)
      end
      
      -- Override termui.open_float_term to position window on the right
      local original_open_float_term = termui.open_float_term
      termui.open_float_term = function(opts)
        opts = opts or {}
        local width = resolve_size(opts.width or 0.4, vim.o.columns)
        local height = resolve_size(opts.height or 0.9, vim.o.lines - vim.o.cmdheight)
        -- Position on the right side instead of center
        local row = math.floor(((vim.o.lines - vim.o.cmdheight) - height) / 2) -- Center vertically
        local col = vim.o.columns - width -- Right side (instead of center)
        
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")
        
        local win = vim.api.nvim_open_win(bufnr, true, {
          relative = "editor",
          row = row,
          col = col,
          width = width,
          height = height,
          style = "minimal",
          border = opts.border or "rounded",
          title = opts.title or "Cursor Agent",
          title_pos = opts.title_pos or "center",
        })
        
        vim.wo[win].wrap = true
        vim.wo[win].cursorline = false
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
        vim.wo[win].signcolumn = "no"
        
        local argv = opts.argv
        local function resolve_cwd(cwd)
          if type(cwd) ~= 'string' or cwd == '' then return vim.fn.getcwd() end
          local uv = vim.uv or vim.loop
          local stat = uv.fs_stat(cwd)
          if stat and stat.type == 'directory' then return cwd end
          return vim.fn.getcwd()
        end
        
        local job_id = vim.fn.termopen(argv, {
          cwd = resolve_cwd(opts.cwd),
          on_exit = function(_, code)
            if type(opts.on_exit) == "function" then
              pcall(opts.on_exit, code)
            end
          end,
        })
        
        pcall(vim.keymap.set, 'n', 'q', function()
          termui.close(win)
        end, { buffer = bufnr, nowait = true, silent = true })
        
        local ok_lines, line_count = pcall(vim.api.nvim_buf_line_count, bufnr)
        if ok_lines then pcall(vim.api.nvim_win_set_cursor, win, { line_count, 0 }) end
        vim.schedule(function()
          pcall(vim.cmd, 'startinsert')
        end)
        
        return bufnr, win, job_id
      end
      
      -- Also override open_float_win_for_buf for the toggle terminal function
      local original_open_float_win_for_buf = termui.open_float_win_for_buf
      if original_open_float_win_for_buf then
        termui.open_float_win_for_buf = function(bufnr, opts)
          opts = opts or {}
          local width = resolve_size(opts.width or 0.4, vim.o.columns)
          local height = resolve_size(opts.height or 0.9, vim.o.lines - vim.o.cmdheight)
          -- Position on the right side instead of center
          local row = math.floor(((vim.o.lines - vim.o.cmdheight) - height) / 2)
          local col = vim.o.columns - width -- Right side
          
          local win = vim.api.nvim_open_win(bufnr, true, {
            relative = "editor",
            row = row,
            col = col,
            width = width,
            height = height,
            style = "minimal",
            border = opts.border or "rounded",
            title = opts.title or "Cursor Agent",
            title_pos = opts.title_pos or "center",
          })
          
          return win
        end
      end
      
      -- Setup the plugin
      cursor_agent.setup({})
    end,
  },
}

