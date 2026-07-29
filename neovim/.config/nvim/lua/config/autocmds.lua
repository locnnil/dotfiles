-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Kernel-tree behavior for C/C++ buffers (does nothing outside a kernel tree).
--
--  * makeprg/errorformat: point `:make` at the kbuild script so errors -> quickfix,
--    independent of the overseer <leader>mb task.
--  * autoformat OFF: whole-file clang-format churns lines you didn't touch and isn't a
--    perfect match for checkpatch.pl. Format your own hunks manually (visual-select +
--    <leader>cf) — clang-format still uses the kernel's in-tree .clang-format — and verify
--    with scripts/checkpatch.pl. Rust is intentionally left alone: rustfmt is canonical and
--    the kernel enforces it (`make rustfmt`). Toggle autoformat per buffer with <leader>uf.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("kernel_c_buffer", { clear = true }),
  pattern = { "c", "cpp" },
  callback = function(ev)
    local kernel = require("util.kernel")
    if kernel.is_kernel(vim.api.nvim_buf_get_name(ev.buf)) then
      vim.bo[ev.buf].makeprg = kernel.build_cmd
      vim.bo[ev.buf].errorformat = kernel.errorformat
      vim.b[ev.buf].autoformat = false
    end
  end,
})
