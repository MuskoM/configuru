local M = {}
function M.get_leader()
  local leader = 'CTRL'
  local base = string.gmatch(os.getenv 'HOME' or "", '[^//]+')()
  if base == 'Users' then
    leader = 'CMD'
  else
    leader = 'CTRL'
  end

  return leader
end

return M
