-- TODO:
-- - dap
-- - dap with cmake-tools
-- - dap with neotest
-- - cmake-tools with lualine instead of nvim-notify

-- disable netrw, use nvim-tree instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = "," -- Make sure to set `mapleader` before lazy so your mappings are correct

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
-- vim.opt.colorcolumn = "80"

require("lazy").setup(
  {
    { "nvim-tree/nvim-tree.lua" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    { "junegunn/fzf", name = "fzf", run = "./install --all" },
    { "junegunn/fzf.vim" },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function () 
        local configs = require("nvim-treesitter.configs")

        configs.setup({
          ensure_installed = { "c", "cpp", "vim" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
        })
      end
    },
    {
      "christoomey/vim-tmux-navigator",
      cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
      },
      keys = {
        { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
        { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
        { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
        { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
        { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
      },
    },
    {
      "folke/trouble.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "L3MON4D3/LuaSnip", -- core nvim snippet engine
        "hrsh7th/nvim-cmp", -- interface for completion sources
        "saadparwaiz1/cmp_luasnip", -- nvim-cmp integration for LuaSnip
        "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for lsp
        --"hrsh7th/cmp-path",
        --"hrsh7th/cmp-cmdline",
        --"j-hui/fidget.nvim",
      },
      config = function ()
      end
    },
    {"artemave/workspace-diagnostics.nvim"},
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "alfaix/neotest-gtest",
      },
    },
    { "jiangmiao/auto-pairs" },
    { "tpope/vim-surround" },
    { "Civitasv/cmake-tools.nvim" },
    { "rcarriga/nvim-notify" }, -- used by cmake-tools
    { 
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
    { "lewis6991/gitsigns.nvim" },
    { "folke/which-key.nvim" },
  }
)

require("neotest").setup({
  adapters = {
    require("neotest-gtest").setup({
      debug_adapter = 'lldb',
      -- exclude external and intermediate directories
      filter_dir = function(name, rel_path, root)
        return name ~= "extern" and name ~= "build"
      end,
    }),
  },
})

require("nvim-tree").setup({
  update_focused_file = { enable = true },
  view = {
    preserve_window_proportions = true,
  },
})

local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup({
  completion = {
    completeopt = 'menu,menuone,noinsert', -- to auto-select first entry
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }),
  snippet = { -- configure how nvim-cmp interacts with snippet engine
	  expand = function(args)
      luasnip.lsp_expand(args.body)
	  end
  },
  matching = { -- disable fuzzy matching for completion
    disallow_fuzzy_matching = true,
    disallow_fullfuzzy_matching = true,
    disallow_partial_fuzzy_matching = true,
    disallow_partial_matching = true,
    disallow_prefix_unmatching = false,
  },
  mapping = cmp.mapping.preset.insert({
    ['<cr>'] = cmp.mapping.confirm({select = true}),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-a>'] = cmp.mapping.abort(),
    ['<C-j>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    ['<C-k>'] = cmp.mapping.select_next_item({behavior = 'select'}),
  }),
})

require('lspconfig').clangd.setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = function(client, bufnr)
    -- trouble
    require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
    -- lsp
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostics - previous' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostics - next' })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename in buffer' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Buffer code action' })
    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })
  end
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.c", "*.cpp", "*.cc"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

require("cmake-tools").setup({
  cmake_build_directory = "build/${variant:buildType}",
  cmake_dap_configuration = {
    name = 'cpp',
    type = 'lldb',
    request = 'launch',
    stopOnEntry = false,
    runInTerminal = true,
    console = 'integratedTerminal',
  },
  cmake_executor = {
    name = 'terminal',
  },
  cmake_runner = {
    name = 'terminal',
  }
})

require("lualine").setup()

require("which-key").setup()

require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git - stage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git - reset hunk' })
    map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Git - stage hunk' })
    map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Git - reset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git - stage buffer' })
    map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Git - undo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git - reset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git - preview hunk' })
    map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end, { desc =  'Git - blame line' })
    map('n', '<leader>htb', gitsigns.toggle_current_line_blame, { desc = 'Git - toggle current line blame' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git - diff against index' })
    map('n', '<leader>hD', function() gitsigns.diffthis('~') end, { desc = 'Git - diff against last commit' })
    map('n', '<leader>htd', gitsigns.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

local dap = require("dap")
local dapui = require("dapui")
dap.adapters.lldb = {
  type = 'executable',
  command = '/opt/homebrew/bin/lldb-dap',
  name = 'lldb',
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function() 
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
    args = {},
    runInTerminal = true,
    env = function()
      local variables = {}
      for k, v in pairs(vim.fn.environ()) do
        table.insert(variables, string.format("%s=%s", k, v))
      end
      return variables
    end,
  },
  {
    -- If you get an "Operation not permitted" error using this, try disabling YAMA:
    --  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    name = "Attach to process",
    type = 'lldb',
    request = 'attach',
    pid = require('dap.utils').pick_process,
    args = {},
    env = function()
      local variables = {}
      for k, v in pairs(vim.fn.environ()) do
        table.insert(variables, string.format("%s=%s", k, v))
      end
      return variables
    end,
    },
}
dap.configurations.c = dap.configurations.cpp

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

vim.cmd.colorscheme('rose-pine-moon')

-- general
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', 'H', '0')
vim.keymap.set('n', 'L', '$')

-- nvim-tree
vim.keymap.set('n', '<leader>ee', ':NvimTreeToggle<cr>')

-- neotest
vim.keymap.set('n', '<leader>tc', function() require("neotest").summary.toggle() end, { desc = 'Test - Toggle Test Panel' })
vim.keymap.set('n', '<leader>tr', function() require("neotest").run.run(vim.fn.getcwd()) end, { desc = 'Test - Run All Tests' })
vim.keymap.set('n', '<leader>td', function() require("neotest").run.run({strategy = "dap"}) end, { desc = 'Test - Debug Current' })

-- fzf
vim.keymap.set('n', '<leader>fa', ':Files<cr>', { desc = 'Find in All Files' })
vim.keymap.set('n', '<leader>ff', ':GFiles<cr>', { desc = 'Find in All Git Files' })
vim.keymap.set('n', '<leader>fm', ':GFiles?<cr>', { desc = 'Find in Modified Git Files' })
vim.keymap.set('n', '<leader>fb', ':Buffers<cr>', { desc = 'Find in Buffers' })
vim.keymap.set('n', '<leader>fg', ':Rg<cr>', { desc = 'Find by file content' })

-- cmake-tools
vim.keymap.set('n', '<leader>cb', ':CMakeBuild<cr>', { desc = 'CMake - Build' })
vim.keymap.set('n', '<leader>cB', ':CMakeBuild!<cr>', { desc = 'CMake - Rebuild' })
vim.keymap.set('n', '<leader>cc', ':CMakeClean<cr>', { desc = 'CMake - Clean' })
vim.keymap.set('n', '<leader>cd', ':CMakeDebug<cr>', { desc = 'CMake - Debug' })
vim.keymap.set('n', '<leader>cg', ':CMakeGenerate<cr>', { desc = 'CMake - Generate' })
vim.keymap.set('n', '<leader>cG', ':CMakeGenerate!<cr>', { desc = 'CMake - Regenerate' })
vim.keymap.set('n', '<leader>cr', ':CMakeRun<cr>', { desc = 'CMake - Run' })
vim.keymap.set('n', '<leader>ct', ':CMakeSelectBuildType<cr>', { desc = 'CMake - Select Build Type' })

-- dap
vim.keymap.set('n', '<leader>dr', ':DapContinue<cr>', { desc = 'Debugger - Run' }) -- r
vim.keymap.set('n', '<leader>da', ':DapTerminate<cr>', { desc = 'Debugger - Terminate' }) 
vim.keymap.set('n', '<leader>dc', ':DapContinue<cr>', { desc = 'Debugger - Continue' }) -- c
vim.keymap.set('n', '<leader>dn', ':DapStepOver<cr>', { desc = 'Debugger - Stop Over' }) -- n, ni
vim.keymap.set('n', '<leader>ds', ':DapStepInto<cr>', { desc = 'Debugger - Stop Into' }) -- s, si
vim.keymap.set('n', '<leader>do', ':DapStepOut<cr>', { desc = 'Debugger - Step Out' }) -- thread step-out
vim.keymap.set('n', '<leader>db', ':DapToggleBreakpoint<cr>', { desc = 'Debugger - Set Breakpoint' }) -- b, br

-- dap-ui
vim.keymap.set('n', '<leader>di', ':lua require("dapui").eval(nil, { enter = true })<cr>', { desc = 'Debugger - Inspect Current Symbol' }) -- b, br
vim.keymap.set('n', '<leader>dI', function()
  local text = vim.fn.input('Symbol: ', '')
  require('dapui').eval(text, { enter = true })
end, { desc = 'Debugger - Inspect Symbol...' }) -- b, br

vim.keymap.set('n', '<Meta-n>', ':DapStepOver<cr>', { desc = 'Debugger - Quick Step Over' }) -- n, ni
vim.keymap.set('n', '<Meta-i>', ':DapStepInto<cr>', { desc = 'Debugger - Quick Step Into' }) -- s, si
vim.keymap.set('n', '<Meta-o>', ':DapStepOut<cr>', { desc = 'Debugger - Quick Step Out' }) -- thread step-out

-- To use the bundled libc++ please add the following LDFLAGS:
-- LDFLAGS="-L/opt/homebrew/opt/llvm/lib/c++ -Wl,-rpath,/opt/homebrew/opt/llvm/lib/c++"

-- llvm is keg-only, which means it was not symlinked into /opt/homebrew,
-- because macOS already provides this software and installing another version in
-- parallel can cause all kinds of trouble.

-- If you need to have llvm first in your PATH, run:
-- echo 'export PATH="/opt/homebrew/opt/llvm/bin:$PATH"' >> ~/.zshrc

-- For compilers to find llvm you may need to set:
-- export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
-- export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
--
-- To use lldp-dap only run:
-- ln -s $(brew --prefix)/opt/llvm/bin/lldb-dap $(brew --prefix)/bin/
