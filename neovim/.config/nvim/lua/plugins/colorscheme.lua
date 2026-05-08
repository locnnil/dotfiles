return {
  {
    "folke/tokyonight.nvim",
    opts = {
      on_highlights = function(hl, _)
        -- Your main windows
        hl.Normal = { bg = "#1e1e2e" }
        hl.NormalNC = { bg = "#16161e" }

        -- Neo-tree (side panel)
        hl.NeoTreeNormal = { bg = "#1e1e2e" }
        hl.NeoTreeNormalNC = { bg = "#16161e" }
      end,
    },
  },
}
