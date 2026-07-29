-- lua/plugins/rust.lua
--
-- Rust-for-Linux navigation. The kernel is NOT a Cargo project: generate a
-- rust-project.json at the tree root with
--   make LLVM=1 rust-analyzer
-- (and confirm the toolchain with `make LLVM=1 rustavailable`). rust-analyzer, which
-- LazyVim drives via rustaceanvim, picks that file up automatically — so opening
-- rust/kernel/lib.rs just works once it exists.
--
-- LazyVim's rust extra uses rustaceanvim (not nvim-lspconfig) to manage rust-analyzer,
-- so the server cmd and kernel-specific settings live here, on vim.g.rustaceanvim.
return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        cmd = { vim.fn.expand("~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/rust-analyzer") },
        default_settings = {
          ["rust-analyzer"] = {
            -- No Cargo in the kernel: don't try to run cargo check / build scripts,
            -- which would only spew errors against a rust-project.json tree.
            cargo = { buildScripts = { enable = false } },
            checkOnSave = false,
            procMacro = { enable = true },
          },
        },
      },
    },
  },
}
