local wz = require 'wezterm'

local M = {}

-- Leader modifier for wezterm's own bindings, or nil for none.
-- macOS: CMD -- it never reaches the terminal, so it cannot collide with
-- Neovim or zellij. Linux: none -- Super belongs to niri and every Ctrl key
-- belongs to Neovim/zellij.
function M.get_leader()
  if wz.target_triple:find 'darwin' then
    return 'CMD'
  end
  return nil
end

return M
