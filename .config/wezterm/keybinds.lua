local wz = require 'wezterm'

local M = {}

-- Splits, panes and tabs belong to zellij; wezterm only keeps its own
-- launcher and command palette, and only when there is a safe leader.
function M.set_keybinds(config, leader)
  if not leader then
    return
  end

  config.leader = { key = 'g', mods = leader, timeout_milliseconds = 1000 }
  config.keys = {
    { key = 'p', mods = 'LEADER', action = wz.action.ActivateCommandPalette },
    { key = 'a', mods = 'LEADER', action = wz.action.ShowLauncher },
  }
end

return M
