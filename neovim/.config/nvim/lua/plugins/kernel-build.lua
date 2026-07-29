-- Fast edit -> build -> fix loop for kernel work, built on overseer.nvim.
--
-- Both the in-editor task below and a plain tmux pane call the SAME script
-- (kernel-dev/kbuild.sh, dropped into the tree as ./scripts/kbuild.sh), so nothing
-- about your tmux workflow changes. Override the command per shell with:
--   export KBUILD_CMD="make LLVM=1 -j$(nproc)"
--
-- Keymaps (under the <leader>m "make" group):
--   <leader>mb  build the kernel; compiler errors populate the quickfix list
--   <leader>mr  re-run the last task
--   <leader>mt  toggle the overseer task panel
-- Jump between quickfix errors with ]q / [q (LazyVim defaults).
--
-- The build command, errorformat and the `:make` fallback all live in util.kernel /
-- config.autocmds so they work whether or not overseer is loaded yet.
return {
  "stevearc/overseer.nvim",
  opts = {
    templates = { "builtin" },
  },
  config = function(_, opts)
    local overseer = require("overseer")
    local kernel = require("util.kernel")
    overseer.setup(opts)

    overseer.register_template({
      name = "kernel build",
      builder = function()
        return {
          cmd = { "/bin/sh", "-c", kernel.build_cmd },
          -- "default" bundles status/notify/dispose; add quickfix parsing on top.
          components = {
            { "on_output_quickfix", errorformat = kernel.errorformat, open_on_match = true, tail = true },
            "default",
          },
        }
      end,
      condition = {
        -- Only offer the task inside a kernel tree.
        callback = function()
          return kernel.is_kernel()
        end,
      },
    })
  end,
  keys = {
    {
      "<leader>mb",
      function()
        if not require("util.kernel").is_kernel() then
          return vim.notify("Not inside a kernel tree", vim.log.levels.WARN, { title = "kernel build" })
        end
        require("overseer").run_template({ name = "kernel build" })
      end,
      desc = "Kernel build (quickfix)",
    },
    {
      "<leader>mr",
      function()
        local tasks = require("overseer").list_tasks({ recent_first = true })
        if tasks[1] then
          require("overseer").run_action(tasks[1], "restart")
        elseif require("util.kernel").is_kernel() then
          require("overseer").run_template({ name = "kernel build" })
        else
          vim.notify("Not inside a kernel tree", vim.log.levels.WARN, { title = "kernel build" })
        end
      end,
      desc = "Kernel build: re-run last",
    },
    { "<leader>mt", "<cmd>OverseerToggle<cr>", desc = "Overseer task panel" },
  },
}
