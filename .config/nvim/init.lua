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

require("lazy").setup("plugins")

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
    vim.keymap.set('n', 'gi', vim.lsp.buf.hover, { desc = 'Display declaration' })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Diagnostics - previous' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Diagnostics - next' })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename in buffer' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Buffer code action' })
    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })
    vim.keymap.set('n', 'gh', '<cmd>ClangdSwitchSourceHeader<cr>', { desc = 'Switch between source and header' })
  end
})

require('lspconfig').rust_analyzer.setup({
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true;
      }
    }
  }
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.c", "*.cpp", "*.cc", "*.h"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

vim.cmd('colorscheme rose-pine-moon')

-- general
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', 'H', '0')
vim.keymap.set('n', 'L', '$')
vim.keymap.set('v', '<leader>p', '"_dp')
vim.keymap.set('n', '<M-,>', '<c-w>5<')
vim.keymap.set('n', '<M-.>', '<c-w>5>')
vim.keymap.set('n', '<M-u>', '<C-W>+5')
vim.keymap.set('n', '<M-d>', '<C-W>-5')

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

vim.filetype.add({
  extension = {
    sf = 'json'
  }
})
