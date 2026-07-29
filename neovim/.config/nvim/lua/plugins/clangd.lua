-- clangd settings that are safe/beneficial for EVERY C/C++ project (kernel or not).
--
-- Anything kernel-specific is NOT here — it lives in the per-tree `.clangd` file
-- (kernel-dev/clangd.template) so it only applies inside a kernel tree:
--   * stripping the GCC-only flags clangd rejects
--   * disabling clang-tidy (kept ON below for your normal C work)
-- clangd auto-discovers that `.clangd` at the tree root, so navigation adapts per
-- project without changing anything global. Kernel navigation itself just needs a
-- compile_commands.json at the tree root:
--   python scripts/clang-tools/gen_compile_commands.py
--
-- These flags REPLACE LazyVim's clangd cmd (the longer list wins), so the LazyVim
-- defaults worth keeping (--completion-style, --function-arg-placeholders,
-- --fallback-style, --clang-tidy) are repeated here.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        -- Use the system clangd (installed via apt) instead of mason.nvim, whose
        -- installer crashes on Neovim 0.11.x (vim.fs expand_home). See INSTALL.md.
        mason = false,
        cmd = {
          "clangd",
          "--background-index",
          -- Index large trees without starving your build of CPU.
          "--background-index-priority=low",
          "-j=4",
          "--pch-storage=memory",
          "--clang-tidy", -- kept on for normal C; kernel's .clangd turns it off in-tree
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          -- Stop clangd hanging on mega-symbols like struct list_head / u32.
          "--limit-references=3000",
          "--limit-results=350",
          -- Let clangd extract builtin include paths from gcc/cross compilers,
          -- so gcc-built compile_commands.json resolves system headers.
          "--query-driver=/usr/bin/*gcc,/usr/bin/*-gcc,/usr/bin/clang*",
        },
      },
    },
  },
}
