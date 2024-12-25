return function(o)
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
