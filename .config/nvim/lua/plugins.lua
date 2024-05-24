return {
  { 
    "nvim-tree/nvim-tree.lua",
    opts = {
      update_focused_file = { enable = true },
      view = { preserve_window_proportions = true },
    },
    keys = {
      { '<leader>ee', ':NvimTreeToggle<cr>', desc = 'test' },
    }
  },
  { "junegunn/fzf", name = "fzf", run = "./install --all" },
  { "ibhagwan/fzf-lua",
    requires = { "nvim-tree/nvim-web-devicons" },
    opts = { "fzf-vim" },
    keys = {
      { '<leader>fa', '<cmd>lua require("fzf-lua").files()<cr>', desc = 'Find in All Files' },
      { '<leader>ff', '<cmd>lua require("fzf-lua").git_files()<cr>', desc = 'Find in All Git Files' },
      { '<leader>fm', '<cmd>lua require("fzf-lua").git_status()<cr>', desc = 'Find in Modified Git Files' },
      { '<leader>fb', '<cmd>lua require("fzf-lua").buffers()<cr>', desc = 'Find in Buffers' },
      { '<leader>fg', '<cmd>lua require("fzf-lua").live_grep()<cr>', desc = 'Find by file content' },
      { '<leader>fs', '<cmd>lua require("fzf-lua").lsp_document_symbols()<cr>', desc = 'Find in buffer symbols' },
      { '<leader>fS', '<cmd>lua require("fzf-lua").lsp_live_workspace_symbols()<cr>', desc = 'Find in all symbols' },
      { '<leader>fd', '<cmd>lua require("fzf-lua").lsp_workspace_diagnostics()<cr>', desc = 'Find in all symbols' },
      { '<leader>fS', '<cmd>lua require("fzf-lua").dap_frames()<cr>', desc = 'Find in stack frames (dap)' },
      { '<leader>fB', '<cmd>lua require("fzf-lua").dap_breakpoints()<cr>', desc = 'Find in breakpoints (dap)' },
      { '<leader>fV', '<cmd>lua require("fzf-lua").dap_variables()<cr>', desc = 'Find in variables(dap)' },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "vim", "json" },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },  
    },
    config = function(_,opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
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
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "alfaix/neotest-gtest",
    },
    keys = {
      { '<leader>tc', function() require("neotest").summary.toggle() end, desc = 'Test - Toggle Test Panel' },
      { '<leader>tr', function() require("neotest").run.run(vim.fn.getcwd()) end, desc = 'Test - Run All Tests' },
      { '<leader>td', function() require("neotest").run.run({strategy = "dap"}) end, desc = 'Test - Debug Current' },
    },
  },
  { "artemave/workspace-diagnostics.nvim" },
  { "jiangmiao/auto-pairs" },
  { "tpope/vim-surround" },
  { "folke/which-key.nvim", opts = {} },
  { "tpope/vim-fugitive" },
  { "j-hui/fidget.nvim", opts = {} },
  { "rcarriga/nvim-notify" }, -- used by cmake-tools
  { 
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { '<leader>a', function() require('harpoon'):list():add() end, desc = 'Harpoon - Add' },
      { '<C-e>', function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, desc = 'Harpoon - Quick Menu' },

      { '<M-h>', function() require('harpoon'):list():select(1) end, desc = 'Harpoon - Select 1' },
      { '<M-j>', function() require('harpoon'):list():select(2) end, desc = 'Harpoon - Select 2' },
      { '<M-k>', function() require('harpoon'):list():select(3) end, desc = 'Harpoon - Select 3' },
      { '<M-l>', function() require('harpoon'):list():select(4) end, desc = 'Harpoon - Select 4' },

      -- Toggle previous & next buffers stored within Harpoon list
      { '<M-i>', function() require('harpoon'):list():prev() end, desc = 'Harpoon - Previous' },
      { '<M-o>', function() require('harpoon'):list():next() end, desc = 'Harpoon - Next' },
    }
  },
}
