dofile(arg[1].."/mock.lua")
dofile(arg[2])
local api = __T3TEST.api
local cases = {
 {1, {xs="", ys="0,1", ren="x", tab="", ev="", g="", cond=""}},
 {1, {xs="0,1", ys="0,1", ren="z", tab=".1,.2,.3,.4", ev="", g="", cond=""}},
 {1, {xs="0,1", ys="0,1", ren="x", tab=".1,.2,.3", ev="", g="", cond=""}},
 {1, {xs="1,2,3,4,5,6", ys="2,3,4,5,6,7,8,9,10,11,12", ren="y",
   tab="1/36,0,0,0,0,0,1/36,1/36,0,0,0,0,1/36,1/36,1/36,0,0,0,1/36,1/36,1/36,1/36,0,0,1/36,1/36,1/36,1/36,1/36,0,1/36,1/36,1/36,1/36,1/36,1/36,0,1/36,1/36,1/36,1/36,1/36,0,0,1/36,1/36,1/36,1/36,0,0,0,1/36,1/36,1/36,0,0,0,0,1/36,1/36,0,0,0,0,0,1/36", ev="x+y>=10", g="", cond="x=3"}},
 {1, {xs="0,1", ys="0,1", ren="x", tab=".1,.2,.3,.4", ev="x>", g="", cond="y=5"}},
 {2, {f="k(x+y)", sop="x>=0, y>=0", ev="", dado=""}},
 {2, {f="e^x", sop="0<=x<=1, 0<=y<=1", ev="", dado=""}},
 {2, {f="k^2 x", sop="0<=x<=1, 0<=y<=1", ev="", dado=""}},
 {2, {f="kxy", sop="0<=x<=1, 0<=y<=1", ev="x^2+y<=1", dado=""}},
 {2, {f="x+y", sop="0<=x<=1, 0<=y<=1", ev="x>5", dado=""}},
 {2, {f="x+y", sop="0<=x<=1, 0<=y<=1", ev="x=y", dado=""}},
 {2, {f="x/y", sop="0<=x<=1, 0<=y<=1", ev="", dado=""}},
 {2, {f="2", sop="0<x<y<1", ev="y>2x", dado=""}},
 {2, {f="6x", sop="0<=x<=y<=1", ev="x+y<=1", dado="y>=1/2"}},
 {3, {f="24xy", sop="x>=0, y>=0, x+y<=1", dado3="y=2", ev3=""}},
 {3, {f="24xy", sop="x>=0, y>=0, x+y<=1", dado3="y<3", ev3=""}},
 {3, {f="24xy", sop="x>=0, y>=0, x+y<=1", dado3="y=1/2", ev3="y<1"}},
 {3, {f="4xy", sop="0<=x<=1, 0<=y<=1", dado3="", ev3=""}},
 {4, {f="(x+2y)/5", sop="0<=x<=1, 0<=y<=2", g4=""}},
 {4, {f="3x", sop="0<=y<=x<=1", g4="x+y"}},
 {5, {a="2,-3", c="5", mu="4,-2", tdis="v", dis="9,4", trel="r", rel="-0.5"}},
 {5, {a="2,-3", c="", mu="4", tdis="v", dis="9,4", trel="r", rel="-0.5"}},
 {5, {a="1/4", c="-3/4", mu="3", tdis="e", dis="25", trel="i", rel=""}},
 {6, {f6="x+y", ord="dzdx", out6="0,1", in6="0,1"}},
 {6, {f6="x+y", ord="dydx", out6="0", in6="0,1"}},
}
for n, c in ipairs(cases) do
  api.select(c[1])
  api.load({n="t", v=c[2]})
  api.solve()
  local _,_,_,lines = api.state()
  local msgs = {}
  for _, l in ipairs(lines) do if l.st=="e" or l.st=="r" then msgs[#msgs+1]=(l.st=="e" and "!! " or "= ")..l.tx end end
  print(n.." [pestaña "..c[1].."] "..table.concat(msgs, " | "):sub(1,300))
end
