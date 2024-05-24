return {
  { 
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      { '<leader>dr', ':DapContinue<cr>', desc = 'Debugger - Run' },
      { '<leader>da', ':DapTerminate<cr>', desc = 'Debugger - Terminate' },
      { '<F5>', ':DapContinue<cr>', desc = 'Debugger - Continue' },
      { '<F10>', ':DapStepOver<cr>', desc = 'Debugger - Stop Over' },
      { '<F11>', ':DapStepInto<cr>', desc = 'Debugger - Stop Into' },
      { '<S-F11>', ':DapStepOut<cr>', desc = 'Debugger - Step Out' },
      { '<leader>db', ':DapToggleBreakpoint<cr>', desc = 'Debugger - Set Breakpoint' },
    },
    config = function()
      local dap = require("dap")
      dap.adapters.lldb = {
        type = 'executable',
        command = '/opt/homebrew/bin/lldb-dap',
        name = 'lldb',
      }
      -- load .vscode/launch.json
      require('dap.ext.vscode').load_launchjs(nil, { lldb = {'c', 'cpp'} })
    end
  },
  { 
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup()

      local debug_win = nil
      local debug_tab = nil
      local debug_tabnr = nil

      local function open_in_tab()
        if debug_win and vim.api.nvim_win_is_valid(debug_win) then
          vim.api.nvim_set_current_win(debug_win)
          return
        end

        vim.cmd('tabedit %')
        debug_win = vim.fn.win_getid()
        debug_tab = vim.api.nvim_win_get_tabpage(debug_win)
        debug_tabnr = vim.api.nvim_tabpage_get_number(debug_tab)

        dapui.open()
      end

      local function close_tab()
        dapui.close()

        if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then
          vim.api.nvim_exec('tabclose ' .. debug_tabnr, false)
        end

        debug_win = nil
        debug_tab = nil
        debug_tabnr = nil
      end

      dap.listeners.after.event_initialized['dapui_config'] = function()
        open_in_tab()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        close_tab()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        close_tab()
      end

      vim.keymap.set('n', '<leader>di', ':lua require("dapui").eval(nil, { enter = true })<cr>', { desc = 'Debugger - Inspect Current Symbol' }) -- b, br
      vim.keymap.set('n', '<leader>dI', 
        function()
          local text = vim.fn.input('Symbol: ', '')
          require('dapui').eval(text, { enter = true })
        end, { desc = 'Debugger - Inspect Symbol...' }
      )

    end,
  },
}
