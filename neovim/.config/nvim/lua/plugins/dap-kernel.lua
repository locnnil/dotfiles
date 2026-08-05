-- Kernel debugging over the QEMU gdbstub, via GDB's native DAP (gdb >= 14).
return {
  "mfussenegger/nvim-dap",
  optional = true,
  opts = function()
    local dap = require("dap")

    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = {
        "--interpreter=dap",
        -- GDB DAP has no `setupCommands`; pre-file commands go here.
        "-iex",
        "set pagination off",
        "-iex",
        "set print pretty on",
        "-iex",
        "set disassembly-flavor intel",
      },
    }

    local cfg = {
      name = "Linux kernel: attach to QEMU :1234",
      type = "gdb",
      request = "attach",
      target = "localhost:1234",
      program = function()
        local root = require("util.kernel").root() or vim.fn.getcwd()
        return vim.fn.input({
          prompt = "vmlinux: ",
          default = root .. "/vmlinux",
          completion = "file",
        })
      end,
    }

    -- APPEND: the clangd extra assigns dap.configurations.c wholesale.
    for _, ft in ipairs({ "c", "cpp" }) do
      dap.configurations[ft] = dap.configurations[ft] or {}
      table.insert(dap.configurations[ft], cfg)
    end
  end,
}
