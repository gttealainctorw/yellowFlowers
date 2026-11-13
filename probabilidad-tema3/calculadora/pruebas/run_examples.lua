dofile(arg[1].."/mock.lua")
dofile(arg[2])
local api = __T3TEST.api
local function plain(lines)
  local out = {}
  for _, l in ipairs(lines) do
    if l.st == "g" then
      for _, r in ipairs(l.rows) do out[#out+1] = "    | " .. table.concat(r, " | ") end
    else
      local pre = ({h="## ", s="  > ", t="    ", r="  = ", n="    (", e="  !! "})[l.st]
      out[#out+1] = pre .. l.tx
    end
  end
  return table.concat(out, "\n")
end
for ti, T in ipairs(api.TOOLS) do
  api.select(ti)
  local exs = T.examples
  if #exs == 0 then local _,_,_,lines = api.state() print("=========== "..T.name) print(plain(lines)) end
  for _, ex in ipairs(exs) do
    api.load(ex)
    api.solve()
    local _, _, _, lines = api.state()
    print("=========== " .. T.name .. " :: " .. ex.n)
    print(plain(lines))
  end
end
