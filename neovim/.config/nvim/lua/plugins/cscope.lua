-- cscope/ctags fallback for kernel navigation.
--
-- Neovim removed native :cscope in 0.9, so this plugin restores it. Use it when
-- clangd's index is still cold, or on trees so large you don't want to wait for it.
-- Generate the databases from the kernel tree root (ARCH matters — it prunes the
-- ~90% of the tree you're not building):
--   make ARCH=x86_64 cscope tags
-- That produces cscope.out (+ ncscope.out) and a `tags` file this plugin reads.
--
-- Keymaps (under the <leader>cs "cscope" group), all populate the quickfix list:
--   <leader>css  find this symbol            <leader>csg  find global definition
--   <leader>csc  find callers of this fn     <leader>csd  find functions this calls
--   <leader>cst  find this text string       <leader>csf  find this file
--   <leader>csi  find files #including this  <leader>csa  find places assigning symbol
--   <leader>csb  (re)build the databases
return {
  "dhananjaylatkar/cscope_maps.nvim",
  event = "VeryLazy",
  opts = {
    disable_maps = true, -- we define our own under <leader>cs below
    cscope = {
      db_file = "./cscope.out",
      exec = "cscope", -- set to "gtags-cscope" if you prefer GNU global
      -- Route results to the quickfix list: no extra picker dependency, and
      -- consistent with the build loop. Switch to "telescope"/"fzf-lua"/"snacks"
      -- (add the matching plugin as a dependency) if you prefer a fuzzy picker.
      picker = "quickfix",
      skip_picker_for_single_result = true,
    },
  },
  keys = {
    -- q = query flavors map to cscope's numbered find modes.
    { "<leader>css", "<cmd>Cscope find s <C-R><C-W><cr>", desc = "cscope: this symbol" },
    { "<leader>csg", "<cmd>Cscope find g <C-R><C-W><cr>", desc = "cscope: global definition" },
    { "<leader>csc", "<cmd>Cscope find c <C-R><C-W><cr>", desc = "cscope: callers of fn" },
    { "<leader>csd", "<cmd>Cscope find d <C-R><C-W><cr>", desc = "cscope: functions called by" },
    { "<leader>cst", "<cmd>Cscope find t <C-R><C-W><cr>", desc = "cscope: this text" },
    { "<leader>cse", "<cmd>Cscope find e <C-R><C-W><cr>", desc = "cscope: egrep pattern" },
    { "<leader>csf", "<cmd>Cscope find f <C-R><C-W><cr>", desc = "cscope: this file" },
    { "<leader>csi", "<cmd>Cscope find i <C-R><C-W><cr>", desc = "cscope: files #including" },
    { "<leader>csa", "<cmd>Cscope find a <C-R><C-W><cr>", desc = "cscope: assignments to symbol" },
    { "<leader>csb", "<cmd>Cscope build<cr>", desc = "cscope: (re)build db" },
  },
}
