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
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
    vim.keymap.set('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
    vim.keymap.set('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')
    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>')
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    vim.keymap.set('n', '<leader>f', '<cmd>vim.lsp.buf.format<cr>')
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
})

require("lualine").setup()

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
    -- runInTerminal = true,
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

-- neotest
vim.keymap.set('n', '<leader>tc', function() require("neotest").summary.toggle() end)
vim.keymap.set('n', '<leader>tr', function() require("neotest").run.run(vim.fn.getcwd()) end)

-- fzf
vim.keymap.set('n', '<leader>fa', ':Files<cr>')
vim.keymap.set('n', '<leader>ff', ':GFiles<cr>')
vim.keymap.set('n', '<leader>fm', ':GFiles?<cr>')
vim.keymap.set('n', '<leader>fb', ':Buffers<cr>')
vim.keymap.set('n', '<leader>fg', ':Rg<cr>')

-- cmake-tools
vim.keymap.set('n', '<leader>cb', ':CMakeBuild<cr>')
vim.keymap.set('n', '<leader>cB', ':CMakeBuild!<cr>')
vim.keymap.set('n', '<leader>cc', ':CMakeClean<cr>')
vim.keymap.set('n', '<leader>cd', ':CMakeDebug<cr>')
vim.keymap.set('n', '<leader>cg', ':CMakeGenerate<cr>')
vim.keymap.set('n', '<leader>cG', ':CMakeGenerate!<cr>')
vim.keymap.set('n', '<leader>cr', ':CMakeRun<cr>')
vim.keymap.set('n', '<leader>ct', ':CMakeSelectBuildType<cr>')

-- dap
vim.keymap.set('n', '<leader>dr', ':DapContinue<cr>') -- r
vim.keymap.set('n', '<leader>dc', ':DapContinue<cr>') -- c
vim.keymap.set('n', '<leader>dn', ':DapStepOver<cr>') -- n, ni
vim.keymap.set('n', '<leader>ds', ':DapStepInto<cr>') -- s, si
vim.keymap.set('n', '<leader>do', ':DapStepOut<cr>') -- thread step-out
vim.keymap.set('n', '<leader>db', ':DapToggleBreakpoint<cr>') -- b, br

vim.keymap.set('n', '<Meta-n>', ':DapStepOver<cr>') -- n, ni
vim.keymap.set('n', '<Meta-i>', ':DapStepInto<cr>') -- s, si
vim.keymap.set('n', '<Meta-o>', ':DapStepOut<cr>') -- thread step-out

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
