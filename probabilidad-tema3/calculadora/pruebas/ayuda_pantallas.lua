dofile(arg[1].."/mock.lua")
dofile(arg[2])
local api = __T3TEST.api
local n = 0
local function shot(name) paint() n = n + 1 dump(string.format("shot_%02d_%s.txt", n, name)) end
api.select(1) menuItem("Ejemplos", "Ej. 3.3 Fábrica") for i=1,5 do on.arrowDown() end shot("t1_form_g")
on.contextMenu() shot("t1_ayuda_g_1") for i=1,8 do on.arrowDown() end shot("t1_ayuda_g_2")
on.escapeKey() shot("t1_regreso")
menuItem("Pestañas", "5 Combinación lineal") on.arrowDown() on.arrowDown() on.arrowDown() menuItem("¿Qué va aquí?", "Este campo") shot("t5_ayuda_tdis")
menuItem("¿Qué va aquí?", "Toda la pestaña") shot("t5_toda")
