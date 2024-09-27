return function(n, color)
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
