dofile(arg[1].."/mock.lua")
dofile(arg[2])
local api = __T3TEST.api
local total, sinayuda = 0, {}
for ti, T in ipairs(api.TOOLS) do
  api.select(ti)
  for i, fd in ipairs(T.fields) do
    total = total + 1
    if not fd.a then sinayuda[#sinayuda+1] = T.name .. "/" .. fd.k end
    api.setField(i) api.help(false) paint()
  end
  if #T.fields > 0 then
    api.help(true) paint()
    local _,_,_,lines = api.state()
    print(T.name .. ": " .. #lines .. " renglones de ayuda")
  end
end
print("campos: " .. total .. "  sin ayuda: " .. (#sinayuda == 0 and "ninguno" or table.concat(sinayuda, ", ")))
