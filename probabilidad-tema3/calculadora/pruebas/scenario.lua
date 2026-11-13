dofile(arg[1].."/mock.lua")
dofile(arg[2])
local api = __T3TEST.api
local n = 0
local function shot(name) paint() n = n + 1 dump(string.format("shot_%02d_%s.txt", n, name)) end
-- pestaña 1, formulario vacío y con ejemplo
api.select(1) shot("t1_form_vacio")
menuItem("Ejemplos", "Ej. 3.3 Fábrica") on.arrowDown() on.arrowDown() on.arrowDown() shot("t1_form_ejemplo")
on.enterKey() shot("t1_out_1")
for i=1,14 do on.arrowDown() end shot("t1_out_2")
on.tabKey() on.tabKey() on.tabKey() shot("t1_out_3")
on.escapeKey() on.arrowDown() on.arrowDown() on.arrowDown() shot("t1_form_campo7")
-- pestaña 2
menuItem("Pestañas", "2 Densidad: k y P") menuItem("Ejemplos", "Serie 2 (banda)") shot("t2_form")
on.enterKey() shot("t2_out_1") for i=1,13 do on.arrowDown() end shot("t2_out_2")
-- pestaña 3
menuItem("Pestañas", "3 Marginal y condicional") menuItem("Ejemplos", "Serie 3 Tabacalera") on.enterKey()
for i=1,14 do on.arrowDown() end shot("t3_out")
-- pestaña 5
menuItem("Pestañas", "5 Combinación lineal") menuItem("Ejemplos", "Autoexamen 9") shot("t5_form") on.enterKey() shot("t5_out")
-- escribir a mano en pestaña 6
menuItem("Pestañas", "6 Integral doble") menuItem("Opciones", "Borrar datos de esta pestaña")
typeText("24xy") on.tabKey() typeText("dydx") on.tabKey() typeText("1/2,1") on.tabKey() typeText("0,1−x") shot("t6_form_tecleado")
on.enterKey() shot("t6_out")
-- error
on.escapeKey() on.clearKey() typeText("0,1-y") on.enterKey() shot("t6_error")
menuItem("Pestañas", "7 Ayuda") shot("t7")
