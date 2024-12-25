return function(str, reps)
  local resultStrList = {}
  string.gsub(str,'[^'..reps..']+',function (w)
    table.insert(resultStrList,w)
  end)
  return resultStrList
end
