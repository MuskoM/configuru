local wz = require 'wezterm'

local function yell()
  wz.log_error 'Keyboard conf'
end

local M = {}

function M.set_theme(config)
  config.color_scheme = 'Batman'
end

return M
