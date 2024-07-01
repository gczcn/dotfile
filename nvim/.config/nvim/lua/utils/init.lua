local M = {}

-- string split
M.split = function(str, reps)
  local resultStrList = {}
  string.gsub(str,'[^'..reps..']+',function (w)
    table.insert(resultStrList,w)
  end)
  return resultStrList
end

M.dump = function(o)
  if type(o) == 'table' then
    local s = ''
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      --s = s .. '[' .. k .. '] = ' .. M.dump(v) .. ','
      -- s = s .. Utils.dump(v) .. ','
      s = s .. Utils.dump(v)
    end
    return s
  else
    return tostring(o)
  end
end

-- get highlight bg color or fg color
M.get_hl = function(n, color)
  local run = true
  local name = n
  while run do
    local hl = vim.api.nvim_get_hl(0, {name = name})

    if hl['link'] == nil then
      run = false
      if hl[color] ~= nil then
        local hi = string.format('%x', hl[color])
        if string.len(hi) ~= 6 then
          for _ = 1, 6 - string.len(hi), 1 do
            hi = '0'.. hi
          end
        end
        return '#' .. hi
      else
        return '#000000'
      end
    end

    name = hl['link']
  end
end

local mode_map = {
  ['n'] = 'NOR',
  ['no'] = 'O-P',
  ['nov'] = 'O-P',
  ['noV'] = 'O-P',
  ['no\22'] = 'O-P',
  ['niI'] = 'N-I',
  ['niR'] = 'N-R',
  ['niV'] = 'N',
  ['nt'] = 'N-T',
  ['v'] = 'VIS',
  ['vs'] = 'V',
  ['V'] = 'V-L',
  ['Vs'] = 'V-L',
  ['\22'] = 'V-B',
  ['\22s'] = 'V-B',
  ['s'] = 'SEL',
  ['S'] = 'S-L',
  ['\19'] = 'S-B',
  ['i'] = 'INS',
  ['ic'] = 'I-C',
  ['ix'] = 'I-X',
  ['R'] = 'REP',
  ['Rc'] = 'R-C',
  ['Rx'] = 'R-X',
  ['Rv'] = 'V-R',
  ['Rvc'] = 'RVC',
  ['Rvx'] = 'RVX',
  ['c'] = 'CMD',
  ['cv'] = 'EX',
  ['ce'] = 'EX',
  ['r'] = 'R',
  ['rm'] = 'M',
  ['r?'] = 'C',
  ['!'] = 'SH',
  ['t'] = 'TERM',
}

M.simple_mode = function()
  return mode_map[vim.api.nvim_get_mode().mode] or '__'
end

return M
