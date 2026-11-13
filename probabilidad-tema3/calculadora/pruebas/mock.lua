-- Simulador minimo de la API Lua de TI-Nspire para pruebas
__T3TEST = {}
DRAW = {}
local W, H = 318, 212
local font = {"sansserif", "r", 10}
local function ulen(s) local n=0 for _ in tostring(s):gmatch("[%z\1-\127\194-\244][\128-\191]*") do n=n+1 end return n end
local function cw() local sz=font[3] local base=({[7]=4.4,[9]=5.4,[10]=6.0,[11]=6.6,[12]=7.2})[sz] or 6 if font[2]:find("b") then base=base*1.08 end return base end
gc = {}
function gc:setFont(a,b,c) font={a,b,c} end
function gc:setColorRGB(r,g,b) DRAW[#DRAW+1]=string.format("C|%d|%d|%d",r,g,b) end
function gc:fillRect(x,y,w,h) DRAW[#DRAW+1]=string.format("F|%d|%d|%d|%d",x,y,w,h) end
function gc:drawRect(x,y,w,h) DRAW[#DRAW+1]=string.format("R|%d|%d|%d|%d",x,y,w,h) end
function gc:drawString(s,x,y,a) DRAW[#DRAW+1]=string.format("S|%d|%d|%s|%s|%d|%s",x,y,font[1],font[2],font[3],s) end
function gc:getStringWidth(s) return math.floor(ulen(s)*cw()+0.5) end
function gc:getStringHeight(s) return ({[7]=10,[9]=12,[10]=13,[11]=14,[12]=15})[font[3]] or 13 end
function gc:clipRect(m,x,y,w,h) if m=="set" then DRAW[#DRAW+1]=string.format("K|%d|%d|%d|%d",x,y,w,h) else DRAW[#DRAW+1]="K|reset" end end
platform = {window = {}}
function platform.window:width() return W end
function platform.window:height() return H end
function platform.window:invalidate() end
on = {}
MENU = nil
toolpalette = {register = function(m) MENU = m end}
function paint() DRAW = {} on.paint(gc) return DRAW end
function dump(path) local f=io.open(path,"w") for _,l in ipairs(DRAW) do f:write(l,"\n") end f:close() end
function menuItem(menuName, itemName)
  for _,m in ipairs(MENU) do if m[1]==menuName then for i=2,#m do if m[i][1]==itemName then m[i][2](menuName,itemName) return true end end end end
  error("no menu item "..menuName.."/"..itemName)
end
function typeText(s) for ch in s:gmatch("[%z\1-\127\194-\244][\128-\191]*") do on.charIn(ch) end end
