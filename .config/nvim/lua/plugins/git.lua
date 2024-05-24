return {
  { 
    "lewis6991/gitsigns.nvim",
    opts = {
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
  }
}
