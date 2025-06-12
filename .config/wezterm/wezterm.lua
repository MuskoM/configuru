local wz = require 'wezterm'
local keybinds = require 'keybinds'
local helpers = require 'helpers'

local C = wz.config_builder()


C.color_scheme = 'catppuccin-macchiato'
C.hide_tab_bar_if_only_one_tab = true
C.use_fancy_tab_bar = false

local leader = helpers.get_leader()

keybinds.set_keybinds(C, leader)

return C
