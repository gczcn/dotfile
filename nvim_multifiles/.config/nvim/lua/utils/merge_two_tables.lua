return function(table1, table2)
  local table = table1
  for k, v in pairs(table2) do
    table[k] = v
  end
  return table
end
