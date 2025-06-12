local keybinds = require 'keybinds'

local C = {}

C.color_scheme = 'catppuccin-macchiato'
C.hide_tab_bar_if_only_one_tab = true
C.use_fancy_tab_bar = false

keybinds.set_keybinds(C)

return C
