local wz = require 'wezterm'
local keybinds = require 'keybinds'
local helpers = require 'helpers'

local C = wz.config_builder()

C.color_scheme = 'Catppuccin Frappe'
C.window_background_opacity = 0.97
C.hide_tab_bar_if_only_one_tab = true
C.use_fancy_tab_bar = false

keybinds.set_keybinds(C, helpers.get_leader())

return C
