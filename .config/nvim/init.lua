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
    { "rose-pine/neovim", name = "rose-pine", priority = 1000, 
      config = function()
        require("rose-pine").setup()
      end
    },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
    },
    { "junegunn/fzf", name = "fzf", run = "./install --all" },
    { "ibhagwan/fzf-lua",
      -- optional for icon support
      requires = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("fzf-lua").setup({ "fzf-vim" })
      end
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function () 
        local configs = require("nvim-treesitter.configs")

        configs.setup({
          ensure_installed = { "c", "cpp", "vim", "json" },
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
    -- { "Civitasv/cmake-tools.nvim" },
    { "rcarriga/nvim-notify" }, -- used by cmake-tools
    { 
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    { "mfussenegger/nvim-dap" },
    { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
    { "lewis6991/gitsigns.nvim" },
    { "folke/which-key.nvim" },
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" }
    },
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
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.expandable() then
          luasnip.expand()
        else
          cmp.confirm({
            select = true,
          })
        end
      else
        fallback()
      end
    end),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
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
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { desc = 'Display declaration' })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostics - previous' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostics - next' })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename in buffer' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Buffer code action' })
    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })
  end
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.c", "*.cpp", "*.cc", "*.h"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

require("lualine").setup()

require("which-key").setup()

require('gitsigns').setup{
  attach_to_untracked = true,
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 350,
  },
  current_line_blame_formatter_opts = {
    relative_time = true
  },
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
    map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'Git - stage hunk' })
    map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'Git - reset hunk' })
    map('v', '<leader>gs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Git - stage hunk' })
    map('v', '<leader>gr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = 'Git - reset hunk' })
    map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'Git - stage buffer' })
    map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'Git - undo stage hunk' })
    map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'Git - reset buffer' })
    map('n', '<leader>gp', gitsigns.preview_hunk_inline, { desc = 'Git - preview hunk' })
    map('n', '<leader>gb', function() gitsigns.blame_line{full=true} end, { desc =  'Git - blame line' })
    map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = 'Git - toggle current line blame' })
    map('n', '<leader>gd', gitsigns.diffthis, { desc = 'Git - diff against index' })
    map('n', '<leader>gD', function() gitsigns.diffthis('~') end, { desc = 'Git - diff against last commit' })
    map('n', '<leader>gtd', gitsigns.toggle_deleted)

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

-- load .vscode/launch.json
require('dap.ext.vscode').load_launchjs(nil, { lldb = {'c', 'cpp'} })

dapui.setup()

--dap ui setup
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

local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<M-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<M-j>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<M-k>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<M-l>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<M-i>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<M-o>", function() harpoon:list():next() end)

vim.cmd('colorscheme rose-pine-moon')

-- general
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', 'H', '0')
vim.keymap.set('n', 'L', '$')
vim.keymap.set('v', '<leader>p', '"_dp')

-- nvim-tree
vim.keymap.set('n', '<leader>ee', ':NvimTreeToggle<cr>')

-- neotest
vim.keymap.set('n', '<leader>tc', function() require("neotest").summary.toggle() end, { desc = 'Test - Toggle Test Panel' })
vim.keymap.set('n', '<leader>tr', function() require("neotest").run.run(vim.fn.getcwd()) end, { desc = 'Test - Run All Tests' })
vim.keymap.set('n', '<leader>td', function() require("neotest").run.run({strategy = "dap"}) end, { desc = 'Test - Debug Current' })

-- fzf
vim.keymap.set('n', '<leader>fa', '<cmd>lua require("fzf-lua").files()<cr>', { desc = 'Find in All Files' })
vim.keymap.set('n', '<leader>ff', '<cmd>lua require("fzf-lua").git_files()<cr>', { desc = 'Find in All Git Files' })
vim.keymap.set('n', '<leader>fm', '<cmd>lua require("fzf-lua").git_status()<cr>', { desc = 'Find in Modified Git Files' })
vim.keymap.set('n', '<leader>fb', '<cmd>lua require("fzf-lua").buffers()<cr>', { desc = 'Find in Buffers' })
vim.keymap.set('n', '<leader>fg', '<cmd>lua require("fzf-lua").live_grep()<cr>', { desc = 'Find by file content' })
vim.keymap.set('n', '<leader>fs', '<cmd>lua require("fzf-lua").lsp_document_symbols()<cr>', { desc = 'Find in buffer symbols' })
vim.keymap.set('n', '<leader>fS', '<cmd>lua require("fzf-lua").lsp_live_workspace_symbols()<cr>', { desc = 'Find in all symbols' })
vim.keymap.set('n', '<leader>fd', '<cmd>lua require("fzf-lua").lsp_workspace_diagnostics()<cr>', { desc = 'Find in all symbols' })
vim.keymap.set('n', '<leader>fS', '<cmd>lua require("fzf-lua").dap_frames()<cr>', { desc = 'Find in stack frames (dap)' })
vim.keymap.set('n', '<leader>fB', '<cmd>lua require("fzf-lua").dap_breakpoints()<cr>', { desc = 'Find in breakpoints (dap)' })
vim.keymap.set('n', '<leader>fV', '<cmd>lua require("fzf-lua").dap_variables()<cr>', { desc = 'Find in variables(dap)' })

-- dap
vim.keymap.set('n', '<leader>dr', ':DapContinue<cr>', { desc = 'Debugger - Run' }) -- r
vim.keymap.set('n', '<leader>da', ':DapTerminate<cr>', { desc = 'Debugger - Terminate' }) 
vim.keymap.set('n', '<leader>dk', ':DapContinue<cr>', { desc = 'Debugger - Continue' }) -- c
vim.keymap.set('n', '<leader>dj', ':DapStepOver<cr>', { desc = 'Debugger - Stop Over' }) -- n, ni
vim.keymap.set('n', '<leader>dl', ':DapStepInto<cr>', { desc = 'Debugger - Stop Into' }) -- s, si
vim.keymap.set('n', '<leader>dh', ':DapStepOut<cr>', { desc = 'Debugger - Step Out' }) -- thread step-out
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
--

vim.filetype.add({
  extension = {
    sf = 'json'
  }
})
