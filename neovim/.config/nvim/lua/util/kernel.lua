-- Detect whether a file lives inside a Linux kernel source tree.
--
-- Kernel-specific behavior (build makeprg, format policy, the overseer build task)
-- is gated on this so it never affects normal C/Rust projects. The kernel root is the
-- unique directory carrying ALL of these signature files.
local M = {}

local markers = { "Makefile", "Kbuild", "Kconfig", "MAINTAINERS" }
local cache = {}

--- Return the kernel-tree root that contains `path` (defaults to the current buffer),
--- or nil if `path` is not inside a kernel tree. Results are cached per directory.
---@param path? string
---@return string|nil
function M.root(path)
  path = path or vim.api.nvim_buf_get_name(0)
  if not path or path == "" then
    return nil
  end
  local dir = vim.fs.dirname(path)
  if cache[dir] ~= nil then
    return cache[dir] or nil
  end

  local function is_root(d)
    for _, m in ipairs(markers) do
      if vim.uv.fs_stat(d .. "/" .. m) == nil then
        return false
      end
    end
    return true
  end

  local root, d = nil, dir
  while d and d ~= "" do
    if is_root(d) then
      root = d
      break
    end
    local parent = vim.fs.dirname(d)
    if parent == d then
      break
    end
    d = parent
  end

  cache[dir] = root or false
  return root
end

--- True when `path` (or the current buffer) is inside a kernel tree.
---@param path? string
---@return boolean
function M.is_kernel(path)
  return M.root(path) ~= nil
end

-- Shared build command + errorformat, used by BOTH the overseer task
-- (plugins/kernel-build.lua) and the `:make` fallback (config/autocmds.lua). Override
-- the command per shell via KBUILD_CMD; by default it runs kernel-dev/kbuild.sh
-- (installed on the side of the tree as ./../scripts/kbuild.sh).
M.build_cmd = "${KBUILD_CMD:-./../scripts/kbuild.sh}"

-- gcc/clang error lines -> quickfix. Kept explicit so it works even if a project
-- overrides the global errorformat.
M.errorformat = table.concat({
  "%f:%l:%c: %trror: %m",
  "%f:%l:%c: %tarning: %m",
  "%f:%l:%c: %tote: %m",
  "%f:%l: %trror: %m",
  "%f:%l: %tarning: %m",
  "%-G%.%#",
}, ",")

return M
