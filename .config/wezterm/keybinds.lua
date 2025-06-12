local wz = require 'wezterm'

local M = {}

function M.set_keybinds(config, leader)
  config.leader = { key = 'g', mods = leader, timeout_milliseconds = 1000 }
  config.keys = {
    {
      key = "h",
      mods = "LEADER",
      action = wz.action.ActivatePaneDirection "Right"
    },
    {
      key = "j",
      mods = "LEADER",
      action = wz.action.ActivatePaneDirection "Down"
    },
    {
      key = "k",
      mods = "LEADER",
      action = wz.action.ActivatePaneDirection "Up"
    },
    {
      key = "l",
      mods = "LEADER",
      action = wz.action.ActivatePaneDirection "Left"
    },
    {
      key = "v",
      mods = "LEADER",
      action = wz.action.SplitVertical { domain = "CurrentPaneDomain" }
    },
    {
      key = "s",
      mods = "LEADER",
      action = wz.action.SplitHorizontal { domain = "CurrentPaneDomain" }
    },
    {
      key = "p",
      mods = "LEADER",
      action = wz.action.ActivateCommandPalette
    },
    {
      key = "q",
      mods = "LEADER",
      action = wz.action.CloseCurrentPane { confirm = false }
    },
    {
      key = "a",
      mods = "LEADER",
      action = wz.action.ShowLauncher
    }
  }
end

return M
