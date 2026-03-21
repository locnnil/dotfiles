return {
  {
    "github/copilot.vim",
    lazy = false, -- load immediately (recommended for copilot)
    config = function()
      -- Optional: disable tab mapping if you want to control it manually
      vim.g.copilot_no_tab_map = true

      -- Example keymap: accept suggestion with Ctrl+J
      vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        silent = true,
      })
    end,
  },
}
