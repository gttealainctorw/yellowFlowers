platform.apilevel = "2.2"
-- =====================================================================
--  TEMA 3 . VARIABLES ALEATORIAS CONJUNTAS
--  Asistente paso a paso para la TI-Nspire CX II (Lua)
--
--  Uso: tecla [menu] -> Pestanas / Ejemplos / Opciones
--       Llena los campos, [enter] resuelve, [esc] regresa a los datos.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Simbolos (con respaldo ASCII por si la letra no los tiene)
-- ---------------------------------------------------------------------
local SYM_U = {int="∫", to="→", le="≤", ge="≥", ne="≠", approx="≈", rho="ρ",
               sig="σ", sqrt="√", ok="✓", sq="²", sum="Σ", dot="·", x="×"}
local SYM_A = {int="S", to="->", le="<=", ge=">=", ne="!=", approx="~", rho="rho",
               sig="s", sqrt="raiz", ok="(ok)", sq="^2", sum="Suma", dot="*", x="x"}
local SYM = SYM_U

-- ---------------------------------------------------------------------
-- 2. Numeros: fracciones exactas (con respaldo decimal si crecen mucho)
-- ---------------------------------------------------------------------
local LIM = 2^52
local function absn(a) if a < 0 then return -a end return a end
local function isint(v) return v == math.floor(v) end
local function igcd(a, b)
  a = absn(a) b = absn(b)
  while b ~= 0 do a, b = b, a % b end
  return a
end
local function fmtint(v) return string.format("%.0f", v) end
local function fmtdec(v)
  if v ~= v then return "?" end
  if isint(v) and absn(v) < 1e15 then return fmtint(v) end
  local s = string.format("%.6g", v)
  if s:find("e") and absn(v) >= 1e-6 and absn(v) < 1e15 then
    s = string.format("%.9f", v):gsub("0+$", ""):gsub("%.$", "")
  end
  return s
end

local Q = {}
Q.__index = Q
local qnew
local function qf(v) return setmetatable({f = v}, Q) end
qnew = function(n, d)
  if d == 0 then error("No se puede dividir entre cero", 0) end
  if d < 0 then n = -n d = -d end
  if n == 0 then n = 0 end
  if not isint(n) or not isint(d) or absn(n) >= LIM or d >= LIM then return qf(n / d) end
  local g = igcd(n, d)
  if g > 1 then n = n / g d = d / g end
  return setmetatable({n = n, d = d}, Q)
end
local function qi(n) return qnew(n, 1) end
local function Qv(a) if a.f then return a.f end return a.n / a.d end
local function toQ(a)
  if getmetatable(a) == Q then return a end
  if isint(a) then return qnew(a, 1) end
  return qf(a)
end
local function qadd(a, b)
  a = toQ(a) b = toQ(b)
  if a.f or b.f then return qf(Qv(a) + Qv(b)) end
  local g = igcd(a.d, b.d)
  local da, db = a.d / g, b.d / g
  local n1, n2, d = a.n * db, b.n * da, a.d * db
  if absn(n1) >= LIM or absn(n2) >= LIM or d >= LIM then return qf(Qv(a) + Qv(b)) end
  return qnew(n1 + n2, d)
end
local function qneg(a)
  a = toQ(a)
  if a.f then return qf(-a.f) end
  if a.n == 0 then return a end
  return setmetatable({n = -a.n, d = a.d}, Q)
end
local function qsub(a, b) return qadd(a, qneg(b)) end
local function qmul(a, b)
  a = toQ(a) b = toQ(b)
  if a.f or b.f then return qf(Qv(a) * Qv(b)) end
  if a.n == 0 or b.n == 0 then return qnew(0, 1) end
  local g1, g2 = igcd(a.n, b.d), igcd(b.n, a.d)
  local n = (a.n / g1) * (b.n / g2)
  local d = (a.d / g2) * (b.d / g1)
  if absn(n) >= LIM or d >= LIM then return qf(Qv(a) * Qv(b)) end
  return qnew(n, d)
end
local function qinv(a)
  a = toQ(a)
  if a.f then
    if a.f == 0 then error("No se puede dividir entre cero", 0) end
    return qf(1 / a.f)
  end
  return qnew(a.d, a.n)
end
local function qdiv(a, b) return qmul(a, qinv(b)) end
local function qiszero(a)
  a = toQ(a)
  if a.f then return absn(a.f) < 1e-12 end
  return a.n == 0
end
local function qsign(a)
  a = toQ(a)
  if qiszero(a) then return 0 end
  if Qv(a) > 0 then return 1 end
  return -1
end
local function qcmp(a, b) return qsign(qsub(a, b)) end
local function qeq(a, b) return qcmp(a, b) == 0 end
local function qpow(a, e)
  local r = qi(1)
  for _ = 1, e do r = qmul(r, a) end
  return r
end
local function qsqrt(a)
  a = toQ(a)
  if a.f or a.n < 0 then return qf(math.sqrt(Qv(a))) end
  local rn = math.floor(math.sqrt(a.n) + 0.5)
  local rd = math.floor(math.sqrt(a.d) + 0.5)
  if rn * rn == a.n and rd * rd == a.d then return qnew(rn, rd) end
  return qf(math.sqrt(Qv(a)))
end
Q.__add = qadd Q.__sub = qsub Q.__mul = qmul Q.__div = qdiv Q.__unm = qneg

local DEC = false   -- true: mostrar decimales (cuando los datos venian en decimales)
local function qstr(a)
  a = toQ(a)
  if a.f then return fmtdec(a.f) end
  if a.d == 1 then return fmtint(a.n) end
  if DEC then
    local d = a.d
    while d % 2 == 0 do d = d / 2 end
    while d % 5 == 0 do d = d / 5 end
    if d == 1 then return fmtdec(a.n / a.d) end
  end
  return fmtint(a.n) .. "/" .. fmtint(a.d)
end
local function qres(a)   -- resultado: fraccion y decimal
  a = toQ(a)
  local s = qstr(a)
  if s:find("/") then s = s .. "  " .. SYM.approx .. " " .. fmtdec(Qv(a)) end
  return s
end
local function qpar(a)   -- entre parentesis si es negativo o fraccion
  local s = qstr(a)
  if s:find("^%-") or s:find("/") then return "(" .. s .. ")" end
  return s
end
local function pp(a) return "(" .. qstr(a) .. ")" end
local function qparse_num(s)
  local ip, fp = s:match("^(%d*)%.?(%d*)$")
  if not ip or (ip == "" and fp == "") then error("Número no valido: " .. s, 0) end
  local n = tonumber((ip ~= "" and ip or "0") .. fp)
  return qnew(n, 10 ^ #fp)
end

-- ---------------------------------------------------------------------
-- 3. Polinomios en k, x, y con coeficientes exactos
-- ---------------------------------------------------------------------
local VN = {"k", "x", "y"}
local VI = {k = 1, x = 2, y = 3}
local Poly = {}
Poly.__index = Poly
local function pnew() return setmetatable({t = {}}, Poly) end
local function ekey(a, b, c) return a .. "," .. b .. "," .. c end
local function pterm(p, e1, e2, e3, c)
  if qiszero(c) then return end
  local kk = ekey(e1, e2, e3)
  local cur = p.t[kk]
  if cur then
    local s = qadd(cur.c, c)
    if qiszero(s) then p.t[kk] = nil else cur.c = s end
  else
    p.t[kk] = {e = {e1, e2, e3}, c = c}
  end
end
local function pconst(q) local p = pnew() pterm(p, 0, 0, 0, toQ(q)) return p end
local function pvar(name)
  local e = {0, 0, 0} e[VI[name]] = 1
  local p = pnew() pterm(p, e[1], e[2], e[3], qi(1)) return p
end
local function padd(a, b)
  local r = pnew()
  for _, t in pairs(a.t) do pterm(r, t.e[1], t.e[2], t.e[3], t.c) end
  for _, t in pairs(b.t) do pterm(r, t.e[1], t.e[2], t.e[3], t.c) end
  return r
end
local function pscale(a, q)
  q = toQ(q)
  local r = pnew()
  for _, t in pairs(a.t) do pterm(r, t.e[1], t.e[2], t.e[3], qmul(t.c, q)) end
  return r
end
local function psub(a, b) return padd(a, pscale(b, -1)) end
local function pmul(a, b)
  local r = pnew()
  for _, s in pairs(a.t) do
    for _, t in pairs(b.t) do
      pterm(r, s.e[1] + t.e[1], s.e[2] + t.e[2], s.e[3] + t.e[3], qmul(s.c, t.c))
    end
  end
  return r
end
local function ppow(a, n)
  local r = pconst(1)
  for _ = 1, n do r = pmul(r, a) end
  return r
end
local function piszero(a) return next(a.t) == nil end
local function pisconst(a)
  for _, t in pairs(a.t) do
    if t.e[1] + t.e[2] + t.e[3] > 0 then return false end
  end
  return true
end
local function pconstval(a)
  local t = a.t["0,0,0"]
  if t then return t.c end
  return qi(0)
end
local function pdegi(a, i)
  local d = -1
  for _, t in pairs(a.t) do if t.e[i] > d then d = t.e[i] end end
  return d
end
local function pdeg(a, name) return pdegi(a, VI[name]) end
local function phas(a, name) return pdeg(a, name) > 0 end
local function pint(a, name)
  local i = VI[name]
  local r = pnew()
  for _, t in pairs(a.t) do
    local e = {t.e[1], t.e[2], t.e[3]}
    e[i] = e[i] + 1
    pterm(r, e[1], e[2], e[3], qdiv(t.c, e[i]))
  end
  return r
end
local function psubst(a, name, q)
  local i = VI[name]
  local r = pnew()
  local pw = {}
  for _, t in pairs(a.t) do
    local n = t.e[i]
    if not pw[n] then pw[n] = ppow(q, n) end
    local e = {t.e[1], t.e[2], t.e[3]}
    e[i] = 0
    local m = pnew()
    pterm(m, e[1], e[2], e[3], t.c)
    r = padd(r, pmul(m, pw[n]))
  end
  return r
end
local function pequal(a, b) return piszero(psub(a, b)) end
local function hasfloat(p)
  for _, t in pairs(p.t) do if t.c.f then return true end end
  return false
end

local function mono_str(e, sub)
  local s = ""
  for i = 1, 3 do
    local n = e[i]
    if n > 0 then
      local base = VN[i]
      if sub and sub[VN[i]] then base = sub[VN[i]] end
      s = s .. base
      if n > 1 then s = s .. "^" .. n end
    end
  end
  return s
end
local function pstr(a, sub)
  local ts = {}
  for _, t in pairs(a.t) do ts[#ts + 1] = t end
  if #ts == 0 then return "0" end
  table.sort(ts, function(p, q)
    local dp, dq = p.e[2] + p.e[3], q.e[2] + q.e[3]
    if dp ~= dq then return dp > dq end
    if p.e[2] ~= q.e[2] then return p.e[2] > q.e[2] end
    if p.e[3] ~= q.e[3] then return p.e[3] > q.e[3] end
    return p.e[1] > q.e[1]
  end)
  if qsign(ts[1].c) < 0 then
    local anypos = false
    for _, t in ipairs(ts) do if qsign(t.c) > 0 then anypos = true end end
    if anypos then
      local rev = {}
      for i = #ts, 1, -1 do rev[#rev + 1] = ts[i] end
      ts = rev
    end
  end
  local out = ""
  for idx, t in ipairs(ts) do
    local neg = qsign(t.c) < 0
    local ac = neg and qneg(t.c) or t.c
    local m = mono_str(t.e, sub)
    local cs
    if m == "" then
      cs = qstr(ac)
    elseif qeq(ac, 1) then
      cs = m
    else
      local q = qstr(ac)
      if q:find("/") or q:find("e") then cs = "(" .. q .. ")" .. m
      elseif m:find("^%(") or m:find("^%d") then cs = q .. m
      else cs = q .. m end
    end
    if idx == 1 then out = (neg and "-" or "") .. cs
    else out = out .. (neg and " - " or " + ") .. cs end
  end
  return out
end
-- texto para sustituir una variable por un polinomio, p. ej. y -> (1 - x)
local function subtxt(p) return "(" .. pstr(p) .. ")" end
-- version compacta (sin espacios) para limites de integrales
local function cpstr(p) return (pstr(p):gsub(" ", "")) end
-- F evaluada textualmente en var = p  (muestra la sustitucion antes de simplificar)
local function pstr_at(F, name, p)
  if piszero(p) then
    local zero = true
    for _, t in pairs(F.t) do if t.e[VI[name]] == 0 then zero = false end end
    if zero then return "0" end
  end
  return pstr(F, {[name] = subtxt(p)})
end

-- polinomios de una sola variable: division y maximo comun divisor
local function ulead(p, i)
  local best = nil
  for _, t in pairs(p.t) do
    if not best or t.e[i] > best.e[i] then best = t end
  end
  return best
end
local function udiv(a, b, i)
  local q, r = pnew(), a
  local lb = ulead(b, i)
  local guard = 0
  while not piszero(r) and guard < 60 do
    local lr = ulead(r, i)
    if lr.e[i] < lb.e[i] then break end
    local e = {0, 0, 0}
    e[i] = lr.e[i] - lb.e[i]
    local m = pnew()
    pterm(m, e[1], e[2], e[3], qdiv(lr.c, lb.c))
    q = padd(q, m)
    r = psub(r, pmul(m, b))
    guard = guard + 1
  end
  return q, r
end
local function ugcd(a, b, i)
  local guard = 0
  while not piszero(b) and guard < 40 do
    local _, r = udiv(a, b, i)
    a, b = b, r
    guard = guard + 1
  end
  local l = ulead(a, i)
  return pscale(a, qinv(l.c))
end
local function lcm(a, b) return a / igcd(a, b) * b end
local function intnorm(N, D, i)
  if hasfloat(N) or hasfloat(D) then return N, D end
  local L = 1
  for _, p in ipairs({N, D}) do
    for _, t in pairs(p.t) do
      L = lcm(L, t.c.d)
      if L > 1e12 then return N, D end
    end
  end
  N, D = pscale(N, L), pscale(D, L)
  local g = 0
  for _, p in ipairs({N, D}) do for _, t in pairs(p.t) do g = igcd(g, t.c.n) end end
  if g > 1 then N, D = pscale(N, qnew(1, g)), pscale(D, qnew(1, g)) end
  local neg, pos = 0, 0
  for _, p in ipairs({N, D}) do
    for _, t in pairs(p.t) do if qsign(t.c) < 0 then neg = neg + 1 else pos = pos + 1 end end
  end
  local l = ulead(D, i)
  if neg > pos or (neg == pos and l and qsign(l.c) < 0) then N, D = pscale(N, -1), pscale(D, -1) end
  return N, D
end
-- simplifica N/D, con D polinomio solo en la variable de indice i
local function simplify_ratio(N, D, i)
  if pisconst(D) then
    local c = pconstval(D)
    if qiszero(c) then error("División entre cero", 0) end
    return pscale(N, qinv(c)), pconst(1)
  end
  if hasfloat(N) or hasfloat(D) then return N, D end
  local groups, order = {}, {}
  for _, t in pairs(N.t) do
    local e = {t.e[1], t.e[2], t.e[3]}
    local ev = e[i]
    e[i] = 0
    local kk = ekey(e[1], e[2], e[3])
    if not groups[kk] then groups[kk] = {e = e, p = pnew()} order[#order + 1] = kk end
    local u = {0, 0, 0}
    u[i] = ev
    pterm(groups[kk].p, u[1], u[2], u[3], t.c)
  end
  local g = D
  for _, kk in ipairs(order) do
    g = ugcd(g, groups[kk].p, i)
    if pdegi(g, i) <= 0 then break end
  end
  if pdegi(g, i) > 0 then
    local N2 = pnew()
    for _, kk in ipairs(order) do
      local q = udiv(groups[kk].p, g, i)
      local m = pnew()
      local e = groups[kk].e
      pterm(m, e[1], e[2], e[3], qi(1))
      N2 = padd(N2, pmul(q, m))
    end
    N = N2
    D = udiv(D, g, i)
  end
  if pisconst(D) then return pscale(N, qinv(pconstval(D))), pconst(1) end
  return intnorm(N, D, i)
end
-- factoriza un polinomio de una variable usando raices racionales
-- devuelve el texto factorizado, o nil si no aporta nada
local function divisors(n)
  n = absn(n)
  local ds = {}
  if n == 0 or n > 1e8 then return ds end
  local i = 1
  while i * i <= n do
    if n % i == 0 then
      ds[#ds + 1] = i
      if i ~= n / i then ds[#ds + 1] = n / i end
    end
    i = i + 1
  end
  return ds
end
local function factor_str(p)
  if piszero(p) or pisconst(p) or hasfloat(p) then return nil end
  local i, nvars = nil, 0
  for vi = 1, 3 do if pdegi(p, vi) > 0 then i = vi nvars = nvars + 1 end end
  if nvars ~= 1 then return nil end
  local v = VN[i]
  local deg = pdegi(p, i)
  if deg < 2 or deg > 8 then return nil end
  -- coeficientes enteros primitivos y principal positivo
  local L = 1
  for _, t in pairs(p.t) do L = lcm(L, t.c.d) end
  local P = pscale(p, L)
  local g = 0
  for _, t in pairs(P.t) do g = igcd(g, t.c.n) end
  P = pscale(P, qnew(1, g))
  local c = qnew(g, L)
  if qsign(ulead(P, i).c) < 0 then P = pscale(P, -1) c = qneg(c) end
  -- potencia de la variable
  local m0 = 99
  for _, t in pairs(P.t) do if t.e[i] < m0 then m0 = t.e[i] end end
  if m0 > 0 then
    local e = {0, 0, 0}
    e[i] = m0
    local mono = pnew()
    pterm(mono, e[1], e[2], e[3], qi(1))
    P = udiv(P, mono, i)
  end
  local factors = {}
  local guard = 0
  while pdegi(P, i) >= 1 and guard < 10 do
    guard = guard + 1
    local a0 = pconstval(P)
    local an = ulead(P, i).c
    if a0.f or an.f then break end
    local found = nil
    for _, pn in ipairs(divisors(a0.n)) do
      for _, qd in ipairs(divisors(an.n)) do
        for _, sg in ipairs({1, -1}) do
          local r = qnew(sg * pn, qd)
          if not found and qiszero(pconstval(psubst(P, v, pconst(r)))) then found = r end
        end
      end
    end
    if not found then break end
    local lin = padd(pscale(pvar(v), found.d), pconst(-found.n))   -- d*v - n
    P = udiv(P, lin, i)
    c = qmul(c, found.d)                                           -- compensar
    local last = factors[#factors]
    if last and qeq(last.r, found) then last.m = last.m + 1
    else factors[#factors + 1] = {r = found, m = 1} end
  end
  -- normaliza P restante (entero primitivo)
  if not pisconst(P) then
    local L2 = 1
    for _, t in pairs(P.t) do L2 = lcm(L2, t.c.d) end
    P = pscale(P, L2)
    c = qdiv(c, L2)
    local g2 = 0
    for _, t in pairs(P.t) do g2 = igcd(g2, t.c.n) end
    P = pscale(P, qnew(1, g2))
    c = qmul(c, g2)
  else
    c = qmul(c, pconstval(P))
    P = pconst(1)
  end
  local nfac = (m0 > 0 and 1 or 0) + #factors + (pisconst(P) and 0 or 1)
  local multi = false
  for _, f in ipairs(factors) do if f.m > 1 then multi = true end end
  if nfac < 2 and not multi then return nil end
  -- texto: (r - v) cuando conviene que quede positivo, como en los apuntes
  local parts = {}
  for _, f in ipairs(factors) do
    local r = f.r
    local s
    if qsign(r) > 0 and (f.m % 2 == 0 or qsign(c) < 0) then
      if f.m % 2 == 1 then c = qneg(c) end
      local a, b = r.n, r.d
      s = "(" .. fmtint(a) .. " - " .. (b == 1 and "" or fmtint(b)) .. v .. ")"
    else
      local a, b = r.n, r.d
      local cs = (b == 1 and "" or fmtint(b)) .. v
      if a > 0 then s = "(" .. cs .. " - " .. fmtint(a) .. ")" else s = "(" .. cs .. " + " .. fmtint(-a) .. ")" end
    end
    if f.m > 1 then s = s .. "^" .. f.m end
    parts[#parts + 1] = s
  end
  local out = ""
  if qeq(c, -1) then out = "-" elseif not qeq(c, 1) then
    local cs = qstr(c)
    if cs:find("/") then cs = "(" .. cs .. ")" end
    out = cs
  end
  if m0 > 0 then out = out .. v .. (m0 > 1 and ("^" .. m0) or "") end
  out = out .. table.concat(parts)
  if not pisconst(P) then out = out .. "(" .. pstr(P) .. ")" end
  return out
end
local function ratio_str(N, D)
  if pisconst(D) and qeq(pconstval(D), 1) then return pstr(N) end
  local fd = factor_str(D)
  if fd then
    local single = fd:match("^%b()$") or fd:match("^%b()%^%d+$")
    return "(" .. pstr(N) .. ")/" .. (single and fd or ("(" .. fd .. ")"))
  end
  return "(" .. pstr(N) .. ")/(" .. pstr(D) .. ")"
end
local function with_factor(p)
  local fs = factor_str(p)
  if fs and fs ~= pstr(p) then return pstr(p) .. " = " .. fs end
  return pstr(p)
end

-- ---------------------------------------------------------------------
-- 4. Lector de expresiones y condiciones
--    Acepta: 24xy  k(x+y)  3x^2  1/2  x<=1  0<=x<=1, x+y<=1  abs(x-y)
-- ---------------------------------------------------------------------
local FUNCS = {abs = true, sqrt = true, min = true, max = true}
local REPL = {{"≤", "<="}, {"≥", ">="}, {"≠", "~="}, {"−", "-"}, {"–", "-"}, {"×", "*"},
              {"·", "*"}, {"÷", "/"}, {"²", "^2"}, {"³", "^3"}, {"√", "sqrt"}}
local function normalize(s)
  for _, r in ipairs(REPL) do
    local a, b = r[1], r[2]
    s = s:gsub(a:gsub("(%W)", "%%%1"), b)
  end
  return s
end
local function tokenize(s)
  s = normalize(s)
  local toks, i, n = {}, 1, #s
  while i <= n do
    local c = s:sub(i, i)
    if c:match("%s") then
      i = i + 1
    elseif c:match("[%d%.]") then
      local j = i
      while j <= n and s:sub(j, j):match("[%d%.]") do j = j + 1 end
      toks[#toks + 1] = {t = "num", v = s:sub(i, j - 1)}
      i = j
    elseif c:match("%a") then
      local j = i
      while j <= n and s:sub(j, j):match("%a") do j = j + 1 end
      local w = s:sub(i, j - 1):lower()
      if FUNCS[w] then toks[#toks + 1] = {t = "fn", v = w}
      elseif w == "and" then toks[#toks + 1] = {t = "and"}
      elseif w == "or" then toks[#toks + 1] = {t = "or"}
      else
        for ch in w:gmatch(".") do toks[#toks + 1] = {t = "id", v = ch} end
      end
      i = j
    else
      local two = s:sub(i, i + 1)
      if two == "<=" or two == ">=" or two == "~=" or two == "!=" or two == "==" then
        local v = two
        if two == "!=" then v = "~=" elseif two == "==" then v = "=" end
        toks[#toks + 1] = {t = "rel", v = v}
        i = i + 2
      elseif c == "<" or c == ">" or c == "=" then
        toks[#toks + 1] = {t = "rel", v = c} i = i + 1
      elseif c == "&" then
        toks[#toks + 1] = {t = "and"} i = i + 1
      elseif c == "," or c == ";" then
        toks[#toks + 1] = {t = "comma"} i = i + 1
      elseif ("+-*/^()"):find(c, 1, true) then
        toks[#toks + 1] = {t = c} i = i + 1
      else
        error("Símbolo no reconocido: " .. c, 0)
      end
    end
  end
  return toks
end
local function parse(s, allowComma)
  local toks = tokenize(s or "")
  if #toks == 0 then error("Campo vacío", 0) end
  local pos, depth = 1, 0
  local function peek() return toks[pos] end
  local function nxt() pos = pos + 1 return toks[pos - 1] end
  local function expect(t)
    local k = peek()
    if not k or k.t ~= t then error("Falta '" .. t .. "'", 0) end
    return nxt()
  end
  local parseOr, parseUnary
  local function parseAtom()
    local k = peek()
    if not k then error("Expresión incompleta", 0) end
    if k.t == "num" then nxt() return {t = "num", q = qparse_num(k.v)} end
    if k.t == "id" then nxt() return {t = "var", n = k.v} end
    if k.t == "fn" then
      nxt() expect("(") depth = depth + 1
      local args = {parseOr()}
      while peek() and peek().t == "comma" do nxt() args[#args + 1] = parseOr() end
      expect(")") depth = depth - 1
      return {t = "fn", n = k.v, args = args}
    end
    if k.t == "(" then
      nxt() depth = depth + 1
      local e = parseOr()
      expect(")") depth = depth - 1
      return e
    end
    error("No esperaba '" .. (k.v or k.t) .. "'", 0)
  end
  local function parsePow()
    local b = parseAtom()
    if peek() and peek().t == "^" then
      nxt()
      return {t = "op", o = "^", a = b, b = parseUnary()}
    end
    return b
  end
  parseUnary = function()
    local k = peek()
    if k and k.t == "-" then nxt() return {t = "neg", a = parseUnary()} end
    if k and k.t == "+" then nxt() return parseUnary() end
    return parsePow()
  end
  local function startsAtom(k)
    return k and (k.t == "num" or k.t == "id" or k.t == "fn" or k.t == "(")
  end
  local function parseTerm()
    local a = parseUnary()
    while true do
      local k = peek()
      if k and (k.t == "*" or k.t == "/") then
        nxt()
        a = {t = "op", o = k.t, a = a, b = parseUnary()}
      elseif startsAtom(k) then
        a = {t = "op", o = "*", a = a, b = parsePow()}
      else
        break
      end
    end
    return a
  end
  local function parseSum()
    local a = parseTerm()
    while peek() and (peek().t == "+" or peek().t == "-") do
      local o = nxt().t
      a = {t = "op", o = o, a = a, b = parseTerm()}
    end
    return a
  end
  local function parseCmp()
    local first = parseSum()
    if not (peek() and peek().t == "rel") then return first end
    local xs, ops = {first}, {}
    while peek() and peek().t == "rel" do
      ops[#ops + 1] = nxt().v
      xs[#xs + 1] = parseSum()
    end
    return {t = "cmp", ops = ops, xs = xs}
  end
  local function parseAnd()
    local a = parseCmp()
    while peek() and (peek().t == "and" or (allowComma and depth == 0 and peek().t == "comma")) do
      nxt()
      a = {t = "and", a = a, b = parseCmp()}
    end
    return a
  end
  parseOr = function()
    local a = parseAnd()
    while peek() and peek().t == "or" do
      nxt()
      a = {t = "or", a = a, b = parseAnd()}
    end
    return a
  end
  local e = parseOr()
  if pos <= #toks then
    local k = toks[pos]
    error("Sobra '" .. (k.v or k.t) .. "' (revisa el campo)", 0)
  end
  return e
end

local function topoly(n)
  if n.t == "num" then return pconst(n.q) end
  if n.t == "var" then
    if not VI[n.n] then error("Letra '" .. n.n .. "' no permitida: usa x, y y k", 0) end
    return pvar(n.n)
  end
  if n.t == "neg" then return pscale(topoly(n.a), -1) end
  if n.t == "op" then
    if n.o == "+" then return padd(topoly(n.a), topoly(n.b)) end
    if n.o == "-" then return psub(topoly(n.a), topoly(n.b)) end
    if n.o == "*" then return pmul(topoly(n.a), topoly(n.b)) end
    if n.o == "/" then
      local d = topoly(n.b)
      if not pisconst(d) then error("Sólo se puede dividir entre números (no entre x, y o k)", 0) end
      return pscale(topoly(n.a), qinv(pconstval(d)))
    end
    if n.o == "^" then
      local e = topoly(n.b)
      local v = pconstval(e)
      if not pisconst(e) or v.f or v.d ~= 1 or v.n < 0 or v.n > 20 then
        error("El exponente debe ser un entero de 0 a 20", 0)
      end
      return ppow(topoly(n.a), v.n)
    end
  end
  if n.t == "fn" then error("Aquí sólo se aceptan polinomios (sin " .. n.n .. ")", 0) end
  error("Aquí va una expresión, no una condición", 0)
end

local function evalq(n, env)
  if n.t == "num" then return n.q end
  if n.t == "var" then
    local v = env[n.n]
    if not v then error("La letra " .. n.n .. " no tiene valor aquí", 0) end
    return v
  end
  if n.t == "neg" then return qneg(evalq(n.a, env)) end
  if n.t == "op" then
    local a, b = evalq(n.a, env), evalq(n.b, env)
    if n.o == "+" then return qadd(a, b) end
    if n.o == "-" then return qsub(a, b) end
    if n.o == "*" then return qmul(a, b) end
    if n.o == "/" then return qdiv(a, b) end
    if n.o == "^" then
      if not b.f and b.d == 1 then
        if b.n >= 0 then return qpow(a, b.n) end
        return qinv(qpow(a, -b.n))
      end
      return qf(Qv(a) ^ Qv(b))
    end
  end
  if n.t == "fn" then
    local args = {}
    for i, a in ipairs(n.args) do args[i] = evalq(a, env) end
    if n.n == "abs" then if qsign(args[1]) < 0 then return qneg(args[1]) end return args[1] end
    if n.n == "sqrt" then return qsqrt(args[1]) end
    if n.n == "min" then if qcmp(args[1], args[2]) <= 0 then return args[1] end return args[2] end
    if n.n == "max" then if qcmp(args[1], args[2]) >= 0 then return args[1] end return args[2] end
  end
  error("Aquí va una expresión, no una condición", 0)
end
local function evalb(n, env)
  if n.t == "cmp" then
    for i, op in ipairs(n.ops) do
      local c = qcmp(evalq(n.xs[i], env), evalq(n.xs[i + 1], env))
      local ok = (op == "<" and c < 0) or (op == "<=" and c <= 0) or (op == ">" and c > 0)
              or (op == ">=" and c >= 0) or (op == "=" and c == 0) or (op == "~=" and c ~= 0)
      if not ok then return false end
    end
    return true
  end
  if n.t == "and" then return evalb(n.a, env) and evalb(n.b, env) end
  if n.t == "or" then return evalb(n.a, env) or evalb(n.b, env) end
  error("Aquí va una condición (con <, >, <=, >= o =)", 0)
end
local function isblank(s) return s == nil or s:match("^%s*$") ~= nil end
local function parseList(s, name)
  if isblank(s) then error("Falta llenar: " .. name, 0) end
  local out = {}
  for item in (s .. ","):gmatch("([^,;]*)[,;]") do
    if not isblank(item) then out[#out + 1] = evalq(parse(item, false), {}) end
  end
  return out
end
local function parseNum(s, name)
  if isblank(s) then error("Falta llenar: " .. name, 0) end
  return evalq(parse(s, false), {})
end
local function letter(s, allowed, name)
  local v = (s or ""):lower():gsub("%s", "")
  for _, a in ipairs(allowed) do if v == a then return v end end
  error("En '" .. name .. "' escribe: " .. table.concat(allowed, ", "), 0)
end

-- ---------------------------------------------------------------------
-- 5. Regiones: desigualdades lineales -> poligono -> piezas de integracion
-- ---------------------------------------------------------------------
local function constraints(node, out)
  out = out or {}
  if node.t == "and" then
    constraints(node.a, out) constraints(node.b, out)
  elseif node.t == "cmp" then
    for i, op in ipairs(node.ops) do
      if op == "=" or op == "~=" then error("En regiones usa <, <=, > o >= (no =)", 0) end
      local D = psub(topoly(node.xs[i]), topoly(node.xs[i + 1]))
      for _, t in pairs(D.t) do
        if t.e[1] > 0 or t.e[2] + t.e[3] > 1 then
          error("Cada condición debe ser una recta (lineal en x y y)", 0)
        end
      end
      if op == ">" or op == ">=" then D = pscale(D, -1) end
      local a = D.t["0,1,0"] and D.t["0,1,0"].c or qi(0)
      local b = D.t["0,0,1"] and D.t["0,0,1"].c or qi(0)
      out[#out + 1] = {a = a, b = b, c = pconstval(D)}
    end
  elseif node.t == "or" then
    error("La región no puede llevar 'or': une las condiciones con coma", 0)
  else
    error("Escribe condiciones como 0<=x<=1, x+y<=1", 0)
  end
  return out
end
local BIG = 10 ^ 6
local function hval(h, p) return qadd(qadd(qmul(h.a, p.x), qmul(h.b, p.y)), h.c) end
local function clip(pts, h)
  local out, n = {}, #pts
  for i = 1, n do
    local P, R = pts[i], pts[i % n + 1]
    local fp, fr = hval(h, P), hval(h, R)
    local sp, sr = qsign(fp), qsign(fr)
    if sp <= 0 then out[#out + 1] = P end
    if (sp < 0 and sr > 0) or (sp > 0 and sr < 0) then
      local t = qdiv(fp, qsub(fp, fr))
      out[#out + 1] = {x = qadd(P.x, qmul(t, qsub(R.x, P.x))), y = qadd(P.y, qmul(t, qsub(R.y, P.y)))}
    end
  end
  local res = {}
  for _, p in ipairs(out) do
    local q = res[#res]
    if not q or not (qeq(q.x, p.x) and qeq(q.y, p.y)) then res[#res + 1] = p end
  end
  if #res > 1 and qeq(res[1].x, res[#res].x) and qeq(res[1].y, res[#res].y) then res[#res] = nil end
  return res
end
local function cross(a, b, c)
  return qsub(qmul(qsub(b.x, a.x), qsub(c.y, a.y)), qmul(qsub(b.y, a.y), qsub(c.x, a.x)))
end
local function region(cons)
  local pts = {{x = qi(-BIG), y = qi(-BIG)}, {x = qi(BIG), y = qi(-BIG)},
               {x = qi(BIG), y = qi(BIG)}, {x = qi(-BIG), y = qi(BIG)}}
  for _, h in ipairs(cons) do
    pts = clip(pts, h)
    if #pts == 0 then return {} end
  end
  local changed = true
  while changed and #pts >= 3 do
    changed = false
    for i = 1, #pts do
      local a, b, c = pts[(i - 2) % #pts + 1], pts[i], pts[i % #pts + 1]
      if qiszero(cross(a, b, c)) then table.remove(pts, i) changed = true break end
    end
  end
  if #pts < 3 then return {} end
  for _, p in ipairs(pts) do
    if absn(Qv(p.x)) >= BIG * 0.999 or absn(Qv(p.y)) >= BIG * 0.999 then
      error("La región no está cerrada: falta algún límite (por ejemplo x<=1)", 0)
    end
  end
  return pts
end
local function vstr(pts)
  local start = 1
  for i, p in ipairs(pts) do
    local b = pts[start]
    local c = qcmp(p.x, b.x)
    if c < 0 or (c == 0 and qcmp(p.y, b.y) < 0) then start = i end
  end
  local s = {}
  for k = 0, #pts - 1 do
    local p = pts[(start - 1 + k) % #pts + 1]
    s[#s + 1] = "(" .. qstr(p.x) .. "," .. qstr(p.y) .. ")"
  end
  return table.concat(s, " ")
end
local function isrect(pts)
  if #pts ~= 4 then return false end
  for i = 1, 4 do
    local p, q = pts[i], pts[i % 4 + 1]
    if not (qeq(p.x, q.x) or qeq(p.y, q.y)) then return false end
  end
  return true
end
-- piezas: afuera ov (numeros a..b), adentro iv (de lo a hi, rectas en ov)
local function slices(pts, ov)
  local iv = (ov == "x") and "y" or "x"
  local function oc(p) if ov == "x" then return p.x end return p.y end
  local function ic(p) if ov == "x" then return p.y end return p.x end
  local xs = {}
  for _, p in ipairs(pts) do
    local v, dup = oc(p), false
    for _, w in ipairs(xs) do if qeq(w, v) then dup = true break end end
    if not dup then xs[#xs + 1] = v end
  end
  table.sort(xs, function(a, b) return qcmp(a, b) < 0 end)
  local res = {}
  for i = 1, #xs - 1 do
    local a, b = xs[i], xs[i + 1]
    local m = qdiv(qadd(a, b), 2)
    local lo, hi, lov, hiv
    for j = 1, #pts do
      local P, R = pts[j], pts[j % #pts + 1]
      local pa, ra = oc(P), oc(R)
      if not qeq(pa, ra) then
        local mn, mx = pa, ra
        if qcmp(mn, mx) > 0 then mn, mx = mx, mn end
        if qcmp(mn, m) <= 0 and qcmp(m, mx) <= 0 then
          local sl = qdiv(qsub(ic(R), ic(P)), qsub(ra, pa))
          local c = qsub(ic(P), qmul(sl, pa))
          local val = qadd(qmul(sl, m), c)
          if not lov or qcmp(val, lov) < 0 then lov = val lo = {sl, c} end
          if not hiv or qcmp(val, hiv) > 0 then hiv = val hi = {sl, c} end
        end
      end
    end
    local function lp(l) return padd(pscale(pvar(ov), l[1]), pconst(l[2])) end
    res[#res + 1] = {a = a, b = b, lo = lp(lo), hi = lp(hi), ov = ov, iv = iv}
  end
  local mg = {}
  for _, s in ipairs(res) do
    local last = mg[#mg]
    if last and pequal(last.lo, s.lo) and pequal(last.hi, s.hi) then last.b = s.b
    else mg[#mg + 1] = s end
  end
  return mg
end
local function best_pieces(pts)
  local px, py = slices(pts, "x"), slices(pts, "y")
  if #py < #px then return py, px end
  return px, py
end

-- ---------------------------------------------------------------------
-- 6. Registro de pasos (lo que se muestra en pantalla)
-- ---------------------------------------------------------------------
local function newLog()
  local lines = {}
  local L = {lines = lines}
  function L.h(t) lines[#lines + 1] = {st = "h", tx = t} end   -- encabezado
  function L.s(t) lines[#lines + 1] = {st = "s", tx = t} end   -- titulo de paso
  function L.t(t) lines[#lines + 1] = {st = "t", tx = t} end   -- texto
  function L.r(t) lines[#lines + 1] = {st = "r", tx = t} end   -- resultado
  function L.n(t) lines[#lines + 1] = {st = "n", tx = t} end   -- nota
  function L.e(t) lines[#lines + 1] = {st = "e", tx = t} end   -- error
  function L.g(rows, hl) lines[#lines + 1] = {st = "g", rows = rows, hl = hl or {}} end
  return L
end
local NOLOG = {h = function() end, s = function() end, t = function() end, r = function() end,
               n = function() end, e = function() end, g = function() end}

-- ---------------------------------------------------------------------
-- 7. Integral doble paso a paso
-- ---------------------------------------------------------------------
local function lim(a, b) return SYM.int .. "[" .. a .. SYM.to .. b .. "]" end
local function int_piece(L, f, s)
  local ov, iv = s.ov, s.iv
  L.t(lim(qstr(s.a), qstr(s.b)) .. " " .. lim(cpstr(s.lo), cpstr(s.hi)) ..
      " (" .. pstr(f) .. ") d" .. iv .. " d" .. ov)
  local F = pint(f, iv)
  L.s("Adentro: integro en " .. iv .. " (" .. ov .. " queda fija)")
  L.t(SYM.int .. "(" .. pstr(f) .. ") d" .. iv .. " = " .. pstr(F))
  L.s("Sustituyo " .. iv .. " = " .. pstr(s.hi) .. " menos " .. iv .. " = " .. pstr(s.lo))
  L.t("[" .. pstr_at(F, iv, s.hi) .. "] - [" .. pstr_at(F, iv, s.lo) .. "]")
  local h = psub(psubst(F, iv, s.hi), psubst(F, iv, s.lo))
  L.t("= " .. pstr(h))
  local G = pint(h, ov)
  L.s("Afuera: integro en " .. ov)
  L.t(SYM.int .. "(" .. pstr(h) .. ") d" .. ov .. " = " .. pstr(G))
  L.s("Evalúo " .. ov .. " = " .. qstr(s.b) .. " menos " .. ov .. " = " .. qstr(s.a))
  local Gb, Ga = psubst(G, ov, pconst(s.b)), psubst(G, ov, pconst(s.a))
  local v = psub(Gb, Ga)
  L.t("(" .. pstr(Gb) .. ") - (" .. pstr(Ga) .. ") = " .. pstr(v))
  return v
end
local function describe_pieces(L, pieces)
  local p1 = pieces[1]
  if p1.ov == "x" then L.t("Flecha vertical: afuera x, adentro y")
  else L.t("Flecha horizontal: afuera y, adentro x") end
  for _, s in ipairs(pieces) do
    L.t("  " .. qstr(s.a) .. SYM.le .. s.ov .. SYM.le .. qstr(s.b) .. ":  " .. s.iv ..
        " entra en " .. pstr(s.lo) .. ", sale en " .. pstr(s.hi))
  end
  if #pieces > 1 then L.n("La flecha cambia de curva: la integral se parte en " .. #pieces .. " piezas.") end
end
local function integrate_region(L, f, pieces)
  local total, parts = pnew(), {}
  for i, s in ipairs(pieces) do
    if #pieces > 1 then L.s("PIEZA " .. i .. " de " .. #pieces) end
    local v = int_piece(L, f, s)
    total = padd(total, v)
    parts[#parts + 1] = "(" .. pstr(v) .. ")"
  end
  if #pieces > 1 then L.t("Sumo las piezas: " .. table.concat(parts, " + ") .. " = " .. pstr(total)) end
  return total
end

-- ---------------------------------------------------------------------
-- 8. Datos compartidos de la densidad (pestanas 2, 3 y 4)
-- ---------------------------------------------------------------------
local function read_density(d, L, verbose)
  local f = topoly(parse(d.f, false))
  local cons = constraints(parse(d.sop, true))
  local pts = region(cons)
  if #pts == 0 then error("El soporte quedó vacío: revisa las desigualdades", 0) end
  L.h("DATOS")
  L.t("f(x,y) = " .. pstr(f))
  L.t("Soporte: " .. d.sop)
  L.t("Vértices de la región: " .. vstr(pts))
  local best = best_pieces(pts)
  if verbose then describe_pieces(L, best) end
  if phas(f, "k") then
    if pdeg(f, "k") > 1 then error("La k debe aparecer sin potencias (k, no k^2)", 0) end
    local LL = verbose and L or NOLOG
    if verbose then
      L.h("HALLAR k")
      L.s("La integral de f sobre todo el soporte vale 1:")
    end
    local tot = integrate_region(LL, f, best)
    local A = tot.t["1,0,0"] and tot.t["1,0,0"].c or qi(0)
    local B = pconstval(tot)
    if qiszero(A) then error("No se puede despejar k", 0) end
    local kv = qdiv(qsub(1, B), A)
    if verbose then
      L.s("Igualo a 1 y despejo:")
      L.t(pstr(tot) .. " = 1")
    end
    L.r("k = " .. qres(kv))
    if not verbose then L.n("(El procedimiento para k está en la pestaña 2.)") end
    f = psubst(f, "k", pconst(kv))
    L.t("Densidad: f(x,y) = " .. pstr(f))
  elseif verbose then
    local tot = integrate_region(NOLOG, f, best)
    if qeq(pconstval(tot), 1) then L.n("Comprobado: la integral sobre el soporte vale 1 " .. SYM.ok)
    else L.e("Ojo: la integral sobre el soporte da " .. qres(pconstval(tot)) .. ", no 1. Revisa f o el soporte.") end
  end
  return f, pts, cons, slices(pts, "x"), slices(pts, "y")
end
local function prob_region(L, f, cons, extra, label)
  local all = {}
  for _, h in ipairs(cons) do all[#all + 1] = h end
  for _, ex in ipairs(extra) do
    for _, h in ipairs(constraints(parse(ex, true))) do all[#all + 1] = h end
  end
  local pts = region(all)
  if #pts == 0 then
    L.t("La región no toca el soporte.")
    L.r(label .. " = 0")
    return qi(0)
  end
  L.t("Región (soporte y condición): vertices " .. vstr(pts))
  local best = best_pieces(pts)
  describe_pieces(L, best)
  local v = pconstval(integrate_region(L, f, best))
  L.r(label .. " = " .. qres(v))
  return v
end

local function marginal(L, f, pieces, v)
  local iv = (v == "x") and "y" or "x"
  local V = v:upper()
  local res = {}
  L.s("Marginal de " .. V .. ": integro en " .. iv .. " (flecha " .. (v == "x" and "vertical" or "horizontal") .. ")")
  local F = pint(f, iv)
  for _, s in ipairs(pieces) do
    L.t("Para " .. qstr(s.a) .. SYM.le .. v .. SYM.le .. qstr(s.b) .. ":")
    L.t("f" .. V .. "(" .. v .. ") = " .. lim(cpstr(s.lo), cpstr(s.hi)) .. " (" .. pstr(f) .. ") d" .. iv)
    L.t("  " .. SYM.int .. "(" .. pstr(f) .. ") d" .. iv .. " = " .. pstr(F))
    L.t("  = [" .. pstr_at(F, iv, s.hi) .. "] - [" .. pstr_at(F, iv, s.lo) .. "]")
    local h = psub(psubst(F, iv, s.hi), psubst(F, iv, s.lo))
    L.t("  = " .. pstr(h))
    local last = res[#res]
    if last and pequal(last.p, h) then last.b = s.b else res[#res + 1] = {a = s.a, b = s.b, p = h} end
  end
  for _, m in ipairs(res) do
    L.r("f" .. V .. "(" .. v .. ") = " .. with_factor(m.p) .. ",  " .. qstr(m.a) .. SYM.le .. v .. SYM.le .. qstr(m.b))
  end
  return res
end
-- ---------------------------------------------------------------------
-- 9. PESTANA 1: tabla discreta
-- ---------------------------------------------------------------------
local function solveTabla(d, L)
  local xs = parseList(d.xs, "Valores de X")
  local ys = parseList(d.ys, "Valores de Y")
  local ren = letter(d.ren, {"x", "y"}, "Renglones")
  local cells = parseList(d.tab, "Celdas")
  local nx, ny = #xs, #ys
  if #cells ~= nx * ny then
    error("Escribiste " .. #cells .. " celdas y deben ser " .. nx .. SYM.x .. ny .. " = " .. (nx * ny), 0)
  end
  DEC = ((d.tab or ""):find("%.") ~= nil) and not ((d.tab or ""):find("/"))
  local f = {}
  for i = 1, nx do f[i] = {} end
  for i = 1, nx do
    for j = 1, ny do
      if ren == "x" then f[i][j] = cells[(i - 1) * ny + j] else f[i][j] = cells[(j - 1) * nx + i] end
    end
  end
  local fx, fy, tot = {}, {}, qi(0)
  for i = 1, nx do fx[i] = qi(0) end
  for j = 1, ny do fy[j] = qi(0) end
  for i = 1, nx do
    for j = 1, ny do
      fx[i] = qadd(fx[i], f[i][j]) fy[j] = qadd(fy[j], f[i][j]) tot = qadd(tot, f[i][j])
    end
  end
  -- tabla en la misma orientacion que la del enunciado
  local function grid(val, mx, my, total, hlfn)
    local rows, hl = {}, {}
    local R, C = ren, (ren == "x") and "y" or "x"
    local nr, nc = (ren == "x") and nx or ny, (ren == "x") and ny or nx
    local rv, cv = (ren == "x") and xs or ys, (ren == "x") and ys or xs
    local head = {R .. "\\" .. C}
    for c = 1, nc do head[#head + 1] = qstr(cv[c]) end
    if mx then head[#head + 1] = "f" .. R:upper() end
    rows[1] = head
    for r = 1, nr do
      local row = {qstr(rv[r])}
      for c = 1, nc do
        local i, j = r, c
        if ren == "y" then i, j = c, r end
        row[#row + 1] = val(i, j)
        if hlfn and hlfn(i, j) then hl[(r + 1) .. "," .. (c + 1)] = true end
      end
      if mx then row[#row + 1] = qstr(ren == "x" and fx[r] or fy[r]) end
      rows[#rows + 1] = row
    end
    if my then
      local last = {"f" .. C:upper()}
      for c = 1, nc do last[#last + 1] = qstr(ren == "x" and fy[c] or fx[c]) end
      last[#last + 1] = total or ""
      rows[#rows + 1] = last
    end
    L.g(rows, hl)
  end
  local function cellval(i, j) return qstr(f[i][j]) end

  L.h("1) TABLA CON MÁRGENES")
  grid(cellval, true, true, qstr(tot))
  if qeq(tot, 1) then L.n("La suma de todas las celdas es 1 " .. SYM.ok)
  else L.e("Las celdas suman " .. qstr(tot) .. ", no 1. Revisa la tabla.") end

  L.h("2) MARGINALES")
  L.s("Marginal de X: para cada x sumo todas sus celdas")
  for i = 1, nx do
    local parts = {}
    for j = 1, ny do parts[#parts + 1] = qstr(f[i][j]) end
    L.t("fX(" .. qstr(xs[i]) .. ") = " .. table.concat(parts, " + ") .. " = " .. qstr(fx[i]))
  end
  L.s("Marginal de Y: para cada y sumo todas sus celdas")
  for j = 1, ny do
    local parts = {}
    for i = 1, nx do parts[#parts + 1] = qstr(f[i][j]) end
    L.t("fY(" .. qstr(ys[j]) .. ") = " .. table.concat(parts, " + ") .. " = " .. qstr(fy[j]))
  end

  local function moments(vals, probs, V)
    local t1, t2, e1, e2 = {}, {}, qi(0), qi(0)
    for i = 1, #vals do
      t1[#t1 + 1] = pp(vals[i]) .. pp(probs[i])
      t2[#t2 + 1] = pp(vals[i]) .. SYM.sq .. pp(probs[i])
      e1 = qadd(e1, qmul(vals[i], probs[i]))
      e2 = qadd(e2, qmul(qmul(vals[i], vals[i]), probs[i]))
    end
    local var = qsub(e2, qmul(e1, e1))
    L.s("Media: cada valor por su probabilidad, y sumo")
    L.t("E(" .. V .. ") = " .. table.concat(t1, " + ") .. " = " .. qstr(e1))
    L.s("Segundo momento: igual, con los valores al cuadrado")
    L.t("E(" .. V .. SYM.sq .. ") = " .. table.concat(t2, " + ") .. " = " .. qstr(e2))
    L.s("Variancia: E(" .. V .. SYM.sq .. ") - [E(" .. V .. ")]" .. SYM.sq)
    L.t("Var(" .. V .. ") = " .. qstr(e2) .. " - " .. pp(e1) .. SYM.sq .. " = " .. qstr(var))
    local sd = qsqrt(var)
    L.r("E(" .. V .. ") = " .. qres(e1))
    L.r("Var(" .. V .. ") = " .. qres(var))
    L.r(SYM.sig .. V .. " = " .. SYM.sqrt .. "Var = " .. qres(sd))
    return e1, var
  end
  L.h("3) MEDIA Y VARIANCIA DE X")
  local EX, VX = moments(xs, fx, "X")
  L.h("4) MEDIA Y VARIANCIA DE Y")
  local EY, VY = moments(ys, fy, "Y")

  L.h("5) E(XY), COVARIANCIA Y CORRELACIÓN")
  local terms, EXY = {}, qi(0)
  for i = 1, nx do
    for j = 1, ny do
      local p = qmul(qmul(xs[i], ys[j]), f[i][j])
      if not qiszero(p) then
        terms[#terms + 1] = pp(xs[i]) .. pp(ys[j]) .. pp(f[i][j])
        EXY = qadd(EXY, p)
      end
    end
  end
  L.s("E(XY): cada celda por su x y su y (las que dan 0 no se escriben)")
  L.t("E(XY) = " .. (#terms > 0 and table.concat(terms, " + ") or "0") .. " = " .. qstr(EXY))
  local cov = qsub(EXY, qmul(EX, EY))
  L.s("Covariancia: E(XY) - E(X)E(Y)")
  L.t("Cov = " .. qstr(EXY) .. " - " .. pp(EX) .. pp(EY) .. " = " .. qstr(cov))
  L.s("Correlación: Cov / (" .. SYM.sig .. "X " .. SYM.sig .. "Y)")
  if qiszero(VX) or qiszero(VY) then
    L.e("Una variancia es 0: la correlación no está definida.")
  else
    local rho2 = qdiv(qmul(cov, cov), qmul(VX, VY))
    local rho = qsqrt(rho2)
    if qsign(cov) < 0 then rho = qneg(rho) end
    L.t(SYM.rho .. " = " .. qpar(cov) .. " / " .. SYM.sqrt .. "(" .. pp(VX) .. pp(VY) .. ") = " .. qres(rho))
    L.r("Cov(X,Y) = " .. qres(cov))
    L.r(SYM.rho .. " = " .. qres(rho))
    L.t(SYM.rho .. SYM.sq .. " (determinación) = " .. qres(rho2))
  end

  L.h("6) ¿SON INDEPENDIENTES?")
  local fail = nil
  for i = 1, nx do
    for j = 1, ny do
      if not fail and not qeq(f[i][j], qmul(fx[i], fy[j])) then fail = {i, j} end
    end
  end
  L.s("Comparo cada celda con fX(x)" .. SYM.dot .. "fY(y)")
  if fail then
    local i, j = fail[1], fail[2]
    L.t("Celda (" .. qstr(xs[i]) .. ", " .. qstr(ys[j]) .. "): f = " .. qstr(f[i][j]))
    L.t("fX" .. SYM.dot .. "fY = " .. qstr(fx[i]) .. " " .. SYM.dot .. " " .. qstr(fy[j]) .. " = " ..
        qstr(qmul(fx[i], fy[j])) .. "  " .. SYM.ne .. " " .. qstr(f[i][j]))
    L.r("NO son independientes (basta una celda que falle)")
  else
    L.t("Las " .. (nx * ny) .. " celdas cumplen f(x,y) = fX(x)" .. SYM.dot .. "fY(y).")
    L.t("Ej.: " .. qstr(fx[1]) .. " " .. SYM.dot .. " " .. qstr(fy[1]) .. " = " .. qstr(f[1][1]))
    L.r("SÍ son independientes")
  end

  local sec = 7
  if not isblank(d.ev) then
    local ev = parse(d.ev, true)
    L.h(sec .. ") EVENTO: " .. d.ev) sec = sec + 1
    L.s("Marco las celdas que cumplen y las sumo")
    local parts, P = {}, qi(0)
    for i = 1, nx do
      for j = 1, ny do
        if evalb(ev, {x = xs[i], y = ys[j]}) then
          parts[#parts + 1] = qstr(f[i][j])
          P = qadd(P, f[i][j])
        end
      end
    end
    grid(cellval, false, false, nil, function(i, j) return evalb(ev, {x = xs[i], y = ys[j]}) end)
    L.t("P = " .. (#parts > 0 and table.concat(parts, " + ") or "0") .. " = " .. qstr(P))
    L.r("P(" .. d.ev .. ") = " .. qres(P))
  end
  if not isblank(d.g) then
    local g = parse(d.g, false)
    L.h(sec .. ") VALOR ESPERADO DE g = " .. d.g) sec = sec + 1
    L.s("Calculo g en cada celda")
    grid(function(i, j) return qstr(evalq(g, {x = xs[i], y = ys[j]})) end, false, false)
    L.s("Multiplico g por la probabilidad de su celda y sumo")
    local parts, E = {}, qi(0)
    for i = 1, nx do
      for j = 1, ny do
        local gv = evalq(g, {x = xs[i], y = ys[j]})
        local p = qmul(gv, f[i][j])
        if not qiszero(p) then parts[#parts + 1] = pp(gv) .. pp(f[i][j]) E = qadd(E, p) end
      end
    end
    L.t("E[g] = " .. (#parts > 0 and table.concat(parts, " + ") or "0") .. " = " .. qstr(E))
    L.r("E[" .. d.g .. "] = " .. qres(E))
  end
  if not isblank(d.cond) then
    local c = parse(d.cond, true)
    local isval = c.t == "cmp" and #c.ops == 1 and c.ops[1] == "=" and
                  ((c.xs[1].t == "var" and c.xs[2].t ~= "var") or (c.xs[2].t == "var" and c.xs[1].t ~= "var"))
    if isval then
      local vn, valnode = c.xs[1], c.xs[2]
      if vn.t ~= "var" then vn, valnode = c.xs[2], c.xs[1] end
      local v, q = vn.n, evalq(valnode, {})
      if v ~= "x" and v ~= "y" then error("La condición debe ser x=valor o y=valor", 0) end
      local w = (v == "x") and "y" or "x"
      L.h(sec .. ") CONDICIONAL DE " .. w:upper() .. " DADO " .. v:upper() .. " = " .. qstr(q)) sec = sec + 1
      local idx = nil
      local vals = (v == "x") and xs or ys
      for t = 1, #vals do if qeq(vals[t], q) then idx = t end end
      if not idx then error(v:upper() .. " = " .. qstr(q) .. " no está en los valores de la tabla", 0) end
      local marg = (v == "x") and fx[idx] or fy[idx]
      local wv = (v == "x") and ys or xs
      L.s("Me quedó con las celdas donde " .. v .. " = " .. qstr(q) .. "; su total es f" .. v:upper() .. "(" .. qstr(q) .. ") = " .. qstr(marg))
      if qiszero(marg) then error("Ese total es 0: no se puede condicionar", 0) end
      L.s("Divido cada celda entre ese total")
      local condp, E, rows = {}, qi(0), {{w, "f(" .. w .. "|" .. v .. "=" .. qstr(q) .. ")"}}
      for t = 1, #wv do
        local cell = (v == "x") and f[idx][t] or f[t][idx]
        condp[t] = qdiv(cell, marg)
        L.t("f(" .. qstr(wv[t]) .. "|" .. qstr(q) .. ") = " .. qstr(cell) .. " / " .. qstr(marg) .. " = " .. qstr(condp[t]))
        rows[#rows + 1] = {qstr(wv[t]), qstr(condp[t])}
        E = qadd(E, qmul(wv[t], condp[t]))
      end
      L.g(rows)
      L.n("Comprueba: la condicional suma 1.")
      local parts = {}
      for t = 1, #wv do parts[#parts + 1] = pp(wv[t]) .. pp(condp[t]) end
      L.t("E[" .. w:upper() .. "|" .. v:upper() .. "=" .. qstr(q) .. "] = " .. table.concat(parts, " + ") .. " = " .. qstr(E))
      L.r("E[" .. w:upper() .. "|" .. v:upper() .. "=" .. qstr(q) .. "] = " .. qres(E))
      if not isblank(d.ev) then
        local ev = parse(d.ev, true)
        local parts2, P = {}, qi(0)
        for t = 1, #wv do
          local env = {}
          env[v] = q
          env[w] = wv[t]
          if evalb(ev, env) then parts2[#parts2 + 1] = qstr(condp[t]) P = qadd(P, condp[t]) end
        end
        L.s("Probabilidad del evento con la condicional")
        L.t("P(" .. d.ev .. " | " .. d.cond .. ") = " .. (#parts2 > 0 and table.concat(parts2, " + ") or "0") .. " = " .. qstr(P))
        L.r("P(" .. d.ev .. " | " .. d.cond .. ") = " .. qres(P))
      end
    else
      L.h(sec .. ") PROBABILIDAD DADO: " .. d.cond) sec = sec + 1
      local PB, PAB = qi(0), qi(0)
      local ev = (not isblank(d.ev)) and parse(d.ev, true) or nil
      for i = 1, nx do
        for j = 1, ny do
          local env = {x = xs[i], y = ys[j]}
          if evalb(c, env) then
            PB = qadd(PB, f[i][j])
            if ev and evalb(ev, env) then PAB = qadd(PAB, f[i][j]) end
          end
        end
      end
      L.t("P(" .. d.cond .. ") = " .. qstr(PB) .. "  (suma de las celdas que cumplen)")
      if ev then
        L.t("P(evento y condición) = " .. qstr(PAB))
        if qiszero(PB) then error("P(condición) = 0", 0) end
        L.t("P(A|B) = P(A y B) / P(B) = " .. qstr(PAB) .. " / " .. qstr(PB))
        L.r("P(" .. d.ev .. " | " .. d.cond .. ") = " .. qres(qdiv(PAB, PB)))
      else
        L.r("P(" .. d.cond .. ") = " .. qres(PB))
        L.n("Para P(A|B) escribe también el evento A.")
      end
    end
  end
  L.h(sec .. ") ACUMULADA F(x,y) = P(X" .. SYM.le .. "x, Y" .. SYM.le .. "y)")
  L.s("Cada celda: suma de las celdas con x y y menores o iguales")
  grid(function(i, j)
    local s = qi(0)
    for a = 1, i do for b = 1, j do s = qadd(s, f[a][b]) end end
    return qstr(s)
  end, false, false)
end

-- ---------------------------------------------------------------------
-- 10. PESTANA 2: densidad, constante y probabilidades
-- ---------------------------------------------------------------------
local function solveDensidad(d, L)
  DEC = false
  local f, pts, cons = read_density(d, L, true)
  if not isblank(d.ev) then
    L.h("P(" .. d.ev .. ")")
    local pa = prob_region(L, f, cons, {d.ev}, "P(" .. d.ev .. ")")
    if not isblank(d.dado) then
      L.h("P(" .. d.dado .. ")  (lo que se da)")
      local pb = prob_region(L, f, cons, {d.dado}, "P(" .. d.dado .. ")")
      L.h("P(A y B): las dos condiciones")
      local pab = prob_region(L, f, cons, {d.ev, d.dado}, "P(A y B)")
      L.h("CONDICIONAL: P(A|B) = P(A y B) / P(B)")
      if qiszero(pb) then error("P(B) = 0: no se puede condicionar", 0) end
      L.t("P(A|B) = " .. qstr(pab) .. " / " .. qstr(pb))
      L.r("P(" .. d.ev .. " | " .. d.dado .. ") = " .. qres(qdiv(pab, pb)))
    end
    return pa
  elseif not isblank(d.dado) then
    L.n("Escribe también el evento A para calcular P(A|B).")
  end
end

-- ---------------------------------------------------------------------
-- 11. PESTANA 3: marginales, condicionales e independencia
-- ---------------------------------------------------------------------
local function solveMarg(d, L)
  DEC = false
  local f, pts, cons, PX, PY = read_density(d, L, false)
  L.h("MARGINAL DE X")
  local mx = marginal(L, f, PX, "x")
  L.h("MARGINAL DE Y")
  local my = marginal(L, f, PY, "y")

  L.h("CONDICIONAL DE Y DADO X = x")
  L.s("Conjunta entre la marginal de lo conocido (X)")
  for _, m in ipairs(mx) do
    local N, D = simplify_ratio(f, m.p, VI.x)
    L.t("f(y|x) = (" .. pstr(f) .. ") / (" .. pstr(m.p) .. ")")
    L.r("f(y|x) = " .. ratio_str(N, D))
    for _, p in ipairs(PX) do
      if qcmp(p.a, m.a) >= 0 and qcmp(p.b, m.b) <= 0 then
        L.t("  para " .. qstr(p.a) .. "<x<" .. qstr(p.b) .. ":  " .. pstr(p.lo) .. SYM.le .. "y" .. SYM.le .. pstr(p.hi))
      end
    end
  end
  L.h("CONDICIONAL DE X DADO Y = y")
  L.s("Conjunta entre la marginal de lo conocido (Y)")
  for _, m in ipairs(my) do
    local N, D = simplify_ratio(f, m.p, VI.y)
    L.t("f(x|y) = (" .. pstr(f) .. ") / (" .. pstr(m.p) .. ")")
    L.r("f(x|y) = " .. ratio_str(N, D))
    for _, p in ipairs(PY) do
      if qcmp(p.a, m.a) >= 0 and qcmp(p.b, m.b) <= 0 then
        L.t("  para " .. qstr(p.a) .. "<y<" .. qstr(p.b) .. ":  " .. pstr(p.lo) .. SYM.le .. "x" .. SYM.le .. pstr(p.hi))
      end
    end
  end

  L.h("¿SON INDEPENDIENTES?")
  if not isrect(pts) then
    L.t("El soporte NO es un rectángulo: los límites de una variable dependen de la otra.")
    L.t("Hay puntos donde f = 0 pero fX y fY son positivas.")
    L.r("NO son independientes")
  else
    local prod = pmul(mx[1].p, my[1].p)
    L.t("Soporte rectangular: comparo fX" .. SYM.dot .. "fY con f(x,y)")
    L.t("fX" .. SYM.dot .. "fY = (" .. pstr(mx[1].p) .. ")(" .. pstr(my[1].p) .. ")")
    L.t("= " .. pstr(prod))
    if pequal(prod, f) then
      L.t("= f(x,y) en todo punto")
      L.r("SÍ son independientes")
    else
      L.t(SYM.ne .. " " .. pstr(f))
      L.r("NO son independientes")
    end
  end

  if not isblank(d.dado3) then
    local c = parse(d.dado3, false)
    if not (c.t == "cmp" and #c.ops == 1 and c.ops[1] == "=") then
      error("En 'valor conocido' escribe algo como y=3/4", 0)
    end
    local vn, valnode = c.xs[1], c.xs[2]
    if vn.t ~= "var" then vn, valnode = c.xs[2], c.xs[1] end
    if vn.t ~= "var" or (vn.n ~= "x" and vn.n ~= "y") then error("Escribe x=valor o y=valor", 0) end
    local v, q = vn.n, evalq(valnode, {})
    local w = (v == "x") and "y" or "x"
    local V, Wn = v:upper(), w:upper()
    L.h("CONDICIONAL DE " .. Wn .. " DADO " .. V .. " = " .. qstr(q))
    local pieces = (v == "x") and PX or PY
    local mp = (v == "x") and mx or my
    local piece = nil
    for _, p in ipairs(pieces) do
      if qcmp(p.a, q) <= 0 and qcmp(q, p.b) <= 0 then piece = p break end
    end
    if not piece then error(V .. " = " .. qstr(q) .. " está fuera del soporte", 0) end
    local fv = nil
    for _, m in ipairs(mp) do
      if qcmp(m.a, q) <= 0 and qcmp(q, m.b) <= 0 then fv = pconstval(psubst(m.p, v, pconst(q))) break end
    end
    local lo, hi = pconstval(psubst(piece.lo, v, pconst(q))), pconstval(psubst(piece.hi, v, pconst(q)))
    local slice = psubst(f, v, pconst(q))
    L.s("1) Intervalo de " .. w .. " cuando " .. v .. " = " .. qstr(q))
    local function lt(pl, q) if pisconst(pl) then return qstr(q) end return pstr(pl) .. " = " .. qstr(q) end
    L.t(w .. " va de " .. lt(piece.lo, lo) .. " a " .. lt(piece.hi, hi))
    L.s("2) Conjunta evaluada en " .. v .. " = " .. qstr(q))
    L.t("f = " .. pstr(f, {[v] = "(" .. qstr(q) .. ")"}) .. " = " .. pstr(slice))
    L.s("3) Marginal evaluada en " .. v .. " = " .. qstr(q))
    L.t("f" .. V .. "(" .. qstr(q) .. ") = " .. qres(fv))
    if qiszero(fv) then error("f" .. V .. "(" .. qstr(q) .. ") = 0: no se puede condicionar", 0) end
    local cond = pscale(slice, qinv(fv))
    L.s("4) Divido")
    L.t("f(" .. w .. "|" .. qstr(q) .. ") = (" .. pstr(slice) .. ") / " .. qpar(fv))
    L.r("f(" .. w .. "|" .. v .. "=" .. qstr(q) .. ") = " .. pstr(cond) .. ",  " .. qstr(lo) .. SYM.le .. w .. SYM.le .. qstr(hi))
    local G = pint(cond, w)
    local chk = qsub(pconstval(psubst(G, w, pconst(hi))), pconstval(psubst(G, w, pconst(lo))))
    L.n("Comprueba: integra " .. qstr(chk) .. " en ese intervalo.")
    local Ge = pint(pmul(pvar(w), cond), w)
    local Ew = qsub(pconstval(psubst(Ge, w, pconst(hi))), pconstval(psubst(Ge, w, pconst(lo))))
    L.t("E[" .. Wn .. "|" .. V .. "=" .. qstr(q) .. "] = " .. lim(qstr(lo), qstr(hi)) .. " " .. w .. "(" .. pstr(cond) .. ") d" .. w .. " = " .. qres(Ew))
    if not isblank(d.ev3) then
      local lo2, hi2 = lo, hi
      for _, h in ipairs(constraints(parse(d.ev3, true))) do
        local a = (w == "x") and h.a or h.b
        local other = (w == "x") and h.b or h.a
        if not qiszero(other) then error("El evento sólo puede usar la letra " .. w, 0) end
        if qiszero(a) then error("El evento debe usar la letra " .. w, 0) end
        local bound = qdiv(qneg(h.c), a)
        if qsign(a) > 0 then if qcmp(bound, hi2) < 0 then hi2 = bound end
        else if qcmp(bound, lo2) > 0 then lo2 = bound end end
      end
      L.h("P(" .. d.ev3 .. " | " .. d.dado3 .. ")")
      if qcmp(lo2, hi2) >= 0 then
        L.t("El evento no cae dentro del intervalo de " .. w .. ".")
        L.r("P = 0")
      else
        L.s("Integro la condicional donde se cumple " .. d.ev3)
        L.t(lim(qstr(lo2), qstr(hi2)) .. " (" .. pstr(cond) .. ") d" .. w)
        L.t("= [" .. pstr(G) .. "] de " .. qstr(lo2) .. " a " .. qstr(hi2))
        local Gb, Ga = pconstval(psubst(G, w, pconst(hi2))), pconstval(psubst(G, w, pconst(lo2)))
        local P = qsub(Gb, Ga)
        L.t("= " .. qpar(Gb) .. " - " .. qpar(Ga) .. " = " .. qstr(P))
        L.r("P(" .. d.ev3 .. " | " .. d.dado3 .. ") = " .. qres(P))
      end
    end
  elseif not isblank(d.ev3) then
    L.n("Para el evento escribe también el valor conocido (ej. y=3/4).")
  end
end

-- ---------------------------------------------------------------------
-- 12. PESTANA 4: E, Cov, correlacion, regresion y E[g]
-- ---------------------------------------------------------------------
local function moment(L, nameE, mp, v, power)
  local total, parts = qi(0), {}
  local mono = v .. (power > 1 and ("^" .. power) or "")
  for _, m in ipairs(mp) do
    local g = pmul(ppow(pvar(v), power), m.p)
    local G = pint(g, v)
    local Gb, Ga = pconstval(psubst(G, v, pconst(m.b))), pconstval(psubst(G, v, pconst(m.a)))
    local val = qsub(Gb, Ga)
    L.t(nameE .. " = " .. lim(qstr(m.a), qstr(m.b)) .. " " .. mono .. "(" .. pstr(m.p) .. ") d" .. v)
    L.t("= " .. SYM.int .. "(" .. pstr(g) .. ") d" .. v .. " = [" .. pstr(G) .. "]")
    L.t("= " .. qpar(Gb) .. " - " .. qpar(Ga) .. " = " .. qstr(val))
    total = qadd(total, val)
    parts[#parts + 1] = qpar(val)
  end
  if #mp > 1 then L.t(nameE .. " = " .. table.concat(parts, " + ") .. " = " .. qstr(total)) end
  return total
end
local function regression(L, f, pieces, mp, v)
  local w = (v == "x") and "y" or "x"
  local V, Wn = v:upper(), w:upper()
  L.s("E[" .. Wn .. "|" .. v .. "] = (" .. SYM.int .. " " .. w .. SYM.dot .. "f d" .. w .. ") / f" .. V .. "(" .. v .. ")")
  L.n("Es lo mismo que integrar " .. w .. SYM.dot .. "f(" .. w .. "|" .. v .. "), porque f" .. V .. " no depende de " .. w .. ".")
  local F = pint(pmul(pvar(w), f), w)
  for _, p in ipairs(pieces) do
    local N = psub(psubst(F, w, p.hi), psubst(F, w, p.lo))
    local D = nil
    for _, m in ipairs(mp) do
      if qcmp(m.a, p.a) <= 0 and qcmp(p.b, m.b) <= 0 then D = m.p end
    end
    if #pieces > 1 then L.t("Para " .. qstr(p.a) .. SYM.le .. v .. SYM.le .. qstr(p.b) .. ":") end
    L.t("Numerador: " .. lim(cpstr(p.lo), cpstr(p.hi)) .. " " .. w .. "(" .. pstr(f) .. ") d" .. w .. " = " .. pstr(N))
    local Nn, Dd = simplify_ratio(N, D, VI[v])
    L.t("E[" .. Wn .. "|" .. v .. "] = (" .. pstr(N) .. ") / (" .. pstr(D) .. ")")
    L.r("E[" .. Wn .. "|" .. v .. "] = " .. ratio_str(Nn, Dd))
    if pisconst(Dd) and pdeg(Nn, v) <= 1 then L.n("Es una recta.") else L.n("No es una recta.") end
  end
end
local function solveMomentos(d, L)
  DEC = false
  local f, pts, cons, PX, PY = read_density(d, L, false)
  local mx = marginal(NOLOG, f, PX, "x")
  local my = marginal(NOLOG, f, PY, "y")
  L.s("Marginales (procedimiento en la pestaña 3):")
  for _, m in ipairs(mx) do L.t("fX(x) = " .. pstr(m.p) .. ",  " .. qstr(m.a) .. SYM.le .. "x" .. SYM.le .. qstr(m.b)) end
  for _, m in ipairs(my) do L.t("fY(y) = " .. pstr(m.p) .. ",  " .. qstr(m.a) .. SYM.le .. "y" .. SYM.le .. qstr(m.b)) end

  L.h("MEDIA Y VARIANCIA DE X (con fX)")
  local EX = moment(L, "E(X)", mx, "x", 1)
  local EX2 = moment(L, "E(X" .. SYM.sq .. ")", mx, "x", 2)
  local VX = qsub(EX2, qmul(EX, EX))
  L.t("Var(X) = E(X" .. SYM.sq .. ") - [E(X)]" .. SYM.sq .. " = " .. qstr(EX2) .. " - " .. qpar(EX) .. SYM.sq .. " = " .. qstr(VX))
  L.r("E(X) = " .. qres(EX))
  L.r("Var(X) = " .. qres(VX))
  L.h("MEDIA Y VARIANCIA DE Y (con fY)")
  local EY = moment(L, "E(Y)", my, "y", 1)
  local EY2 = moment(L, "E(Y" .. SYM.sq .. ")", my, "y", 2)
  local VY = qsub(EY2, qmul(EY, EY))
  L.t("Var(Y) = E(Y" .. SYM.sq .. ") - [E(Y)]" .. SYM.sq .. " = " .. qstr(EY2) .. " - " .. qpar(EY) .. SYM.sq .. " = " .. qstr(VY))
  L.r("E(Y) = " .. qres(EY))
  L.r("Var(Y) = " .. qres(VY))

  L.h("E(XY) CON LA CONJUNTA")
  local best = best_pieces(pts)
  describe_pieces(L, best)
  local EXY = pconstval(integrate_region(L, pmul(pmul(pvar("x"), pvar("y")), f), best))
  L.r("E(XY) = " .. qres(EXY))

  L.h("COVARIANCIA Y CORRELACIÓN")
  local cov = qsub(EXY, qmul(EX, EY))
  L.t("Cov = E(XY) - E(X)E(Y) = " .. qstr(EXY) .. " - " .. pp(EX) .. pp(EY) .. " = " .. qstr(cov))
  local rho2 = qdiv(qmul(cov, cov), qmul(VX, VY))
  local rho = qsqrt(rho2)
  if qsign(cov) < 0 then rho = qneg(rho) end
  L.t(SYM.rho .. " = Cov / " .. SYM.sqrt .. "(Var(X)Var(Y)) = " .. qpar(cov) .. " / " .. SYM.sqrt .. "(" .. pp(VX) .. pp(VY) .. ")")
  L.r("Cov(X,Y) = " .. qres(cov))
  L.r(SYM.rho .. " = " .. qres(rho))
  L.t(SYM.rho .. SYM.sq .. " (determinación) = " .. qres(rho2))

  L.h("CURVA DE REGRESIÓN DE Y DADO x")
  regression(L, f, PX, mx, "x")
  L.h("CURVA DE REGRESIÓN DE X DADO y")
  regression(L, f, PY, my, "y")

  if not isblank(d.g4) then
    L.h("E[" .. d.g4 .. "]")
    local g = topoly(parse(d.g4, false))
    L.s("Multiplico g por la conjunta e integro sobre el soporte")
    L.t("g" .. SYM.dot .. "f = (" .. pstr(g) .. ")(" .. pstr(f) .. ") = " .. pstr(pmul(g, f)))
    describe_pieces(L, best)
    local Eg = pconstval(integrate_region(L, pmul(g, f), best))
    L.r("E[" .. d.g4 .. "] = " .. qres(Eg))
  end
end

-- ---------------------------------------------------------------------
-- 13. PESTANA 5: combinacion lineal
-- ---------------------------------------------------------------------
local function solveLineal(d, L)
  local a = parseList(d.a, "Coeficientes")
  local n = #a
  local c = isblank(d.c) and qi(0) or parseNum(d.c, "Constante")
  local mu = parseList(d.mu, "Medias")
  if #mu ~= n then error("Escribe " .. n .. " medias (una por coeficiente)", 0) end
  local td = letter(d.tdis, {"v", "s", "e"}, "Te dan")
  local dis = parseList(d.dis, "Valores de dispersión")
  if #dis ~= n then error("Escribe " .. n .. " valores de dispersión", 0) end
  local tr = letter(d.trel, {"c", "r", "i"}, "Relación")
  local npairs = n * (n - 1) / 2
  local rel = {}
  if tr ~= "i" and npairs > 0 then
    rel = parseList(d.rel, "Valores de relación")
    if #rel ~= npairs then error("Escribe " .. npairs .. " valores de relación (12,13,23,...)", 0) end
  end
  local all = (d.a or "") .. (d.mu or "") .. (d.dis or "") .. (d.rel or "") .. (d.c or "")
  DEC = all:find("%.") ~= nil and not all:find("/")
  local nm = {}
  if n == 1 then nm = {"X"} elseif n == 2 then nm = {"X", "Y"}
  else for i = 1, n do nm[i] = "X" .. i end end

  local wtx = "W = "
  for i = 1, n do
    local s = qstr(a[i])
    if i > 1 then if qsign(a[i]) < 0 then wtx = wtx .. " - " s = qstr(qneg(a[i])) else wtx = wtx .. " + " end end
    wtx = wtx .. (s == "1" and "" or (s:find("/") and "(" .. s .. ")" or s)) .. nm[i]
  end
  if not qiszero(c) then wtx = wtx .. (qsign(c) < 0 and " - " .. qstr(qneg(c)) or " + " .. qstr(c)) end

  L.h("1) JUNTO LOS DATOS")
  L.t(wtx)
  local V, S = {}, {}
  for i = 1, n do
    if td == "v" then
      V[i] = dis[i]
      L.t("Var(" .. nm[i] .. ") = " .. qstr(V[i]))
    elseif td == "s" then
      V[i] = qmul(dis[i], dis[i])
      L.t("Var(" .. nm[i] .. ") = " .. SYM.sig .. SYM.sq .. " = " .. pp(dis[i]) .. SYM.sq .. " = " .. qstr(V[i]))
    else
      V[i] = qsub(dis[i], qmul(mu[i], mu[i]))
      L.t("Var(" .. nm[i] .. ") = E(" .. nm[i] .. SYM.sq .. ") - [E(" .. nm[i] .. ")]" .. SYM.sq .. " = " .. qstr(dis[i]) .. " - " .. pp(mu[i]) .. SYM.sq .. " = " .. qstr(V[i]))
    end
    S[i] = qsqrt(V[i])
  end
  local cov, k = {}, 0
  for i = 1, n do
    for j = i + 1, n do
      k = k + 1
      local key = i .. "," .. j
      if tr == "i" then
        cov[key] = qi(0)
      elseif tr == "c" then
        cov[key] = rel[k]
        L.t("Cov(" .. nm[i] .. "," .. nm[j] .. ") = " .. qstr(rel[k]))
      else
        cov[key] = qmul(qmul(rel[k], S[i]), S[j])
        L.t("Cov(" .. nm[i] .. "," .. nm[j] .. ") = " .. SYM.rho .. SYM.dot .. SYM.sig .. nm[i] .. SYM.dot .. SYM.sig .. nm[j] ..
            " = " .. pp(rel[k]) .. pp(S[i]) .. pp(S[j]) .. " = " .. qstr(cov[key]))
      end
    end
  end
  if tr == "i" and n > 1 then L.t("Son independientes " .. SYM.to .. " todas las covariancias valen 0") end

  L.h("2) MEDIA DE W")
  L.s("Cada coeficiente por su media, más la constante")
  local parts, E = {}, c
  for i = 1, n do
    parts[#parts + 1] = pp(a[i]) .. pp(mu[i])
    E = qadd(E, qmul(a[i], mu[i]))
  end
  local etx = table.concat(parts, " + ")
  if not qiszero(c) then etx = etx .. " + " .. qpar(c) end
  L.t("E(W) = " .. etx .. " = " .. qstr(E))
  L.r("E(W) = " .. qres(E))

  L.h("3) VARIANCIA DE W")
  L.n("La constante no cambia la variancia. Coeficientes al cuadrado.")
  L.s("Parte de los cuadrados: a" .. SYM.sq .. SYM.dot .. "Var")
  local sq, ps = qi(0), {}
  for i = 1, n do
    ps[#ps + 1] = pp(a[i]) .. SYM.sq .. pp(V[i])
    sq = qadd(sq, qmul(qmul(a[i], a[i]), V[i]))
  end
  L.t(table.concat(ps, " + ") .. " = " .. qstr(sq))
  local cr = qi(0)
  if n > 1 then
    L.s("Parte cruzada: una por cada pareja, a_i" .. SYM.dot .. "a_j" .. SYM.dot .. "Cov")
    local pc = qi(0)
    for i = 1, n do
      for j = i + 1, n do
        local v = qmul(qmul(a[i], a[j]), cov[i .. "," .. j])
        L.t("(" .. nm[i] .. "," .. nm[j] .. "): " .. pp(a[i]) .. pp(a[j]) .. pp(cov[i .. "," .. j]) .. " = " .. qstr(v))
        pc = qadd(pc, v)
      end
    end
    cr = qmul(2, pc)
    L.t("2 " .. SYM.x .. " " .. qpar(pc) .. " = " .. qstr(cr))
  end
  local var = qadd(sq, cr)
  L.s("Sumo las dos partes")
  L.t("Var(W) = " .. qstr(sq) .. " + " .. qpar(cr) .. " = " .. qstr(var))
  L.r("Var(W) = " .. qres(var))
  L.r(SYM.sig .. "W = " .. SYM.sqrt .. "Var(W) = " .. qres(qsqrt(var)))
end

-- ---------------------------------------------------------------------
-- 14. PESTANA 6: integral doble con limites dados
-- ---------------------------------------------------------------------
local function solveIntegral(d, L)
  DEC = false
  local f = topoly(parse(d.f6, false))
  local ord = letter(d.ord, {"dydx", "dxdy"}, "Orden")
  local ov, iv = "x", "y"
  if ord == "dxdy" then ov, iv = "y", "x" end
  local ab = parseList(d.out6, "Límites de afuera")
  if #ab ~= 2 then error("Afuera escribe dos números: desde, hasta", 0) end
  local raw = {}
  for item in ((d.in6 or "") .. ","):gmatch("([^,;]*)[,;]") do
    if not isblank(item) then raw[#raw + 1] = item end
  end
  if #raw ~= 2 then error("Adentro escribe dos límites separados por coma", 0) end
  local lo, hi = topoly(parse(raw[1], false)), topoly(parse(raw[2], false))
  if phas(lo, iv) or phas(hi, iv) or phas(lo, "k") or phas(hi, "k") then
    error("Los límites de adentro sólo pueden tener la letra " .. ov, 0)
  end
  L.h("INTEGRAL DOBLE PASO A PASO")
  local v = int_piece(L, f, {a = ab[1], b = ab[2], lo = lo, hi = hi, ov = ov, iv = iv})
  L.r("Resultado = " .. (pisconst(v) and qres(pconstval(v)) or pstr(v)))
end

-- ---------------------------------------------------------------------
-- 15. PESTANA 7: ayuda
-- ---------------------------------------------------------------------
local function solveAyuda(d, L)
  L.h("¿QUÉ PESTAÑA USO?")
  L.t("1 Tabla discreta: te dan una TABLA f(x,y). Da marginales, medias, variancias, Cov, " .. SYM.rho ..
      ", independencia, evento, E[g], condicional y F(x,y).")
  L.t("2 Densidad: k y P: te dan f(x,y) con una constante o piden P(región) o P(A|B).")
  L.t("3 Marginal y condicional: piden fX, fY, f(y|x), f(x|y), P(X<a | Y=b) o si son independientes.")
  L.t("4 E, Cov y regresión: piden E(X), Var, E(XY), Cov, " .. SYM.rho .. ", curva de regresión o E[g(X,Y)] con densidad.")
  L.t("5 Combinación lineal: te dan medias, variancias (o " .. SYM.sig .. ", o E(X" .. SYM.sq .. ")) y Cov (o " .. SYM.rho .. ") y piden E o Var de aX+bY+c.")
  L.t("6 Integral doble: ya tienes los límites y quieres la cuenta paso a paso.")
  L.h("CÓMO ESCRIBIR")
  L.t("Multiplicación sin *: 24xy, k(x+y), 3x^2y.")
  L.t("Fracciones con /: 3/4.  Decimales: 0.05 o .05")
  L.t("Constante desconocida: siempre k. Si el enunciado trae x y^2/a, escribe kxy^2 y al final a = 1/k.")
  L.t("Regiones: desigualdades separadas por coma: 0<=x<=1, 0<=y, x+y<=1. Sirven " .. SYM.le .. " y <=.")
  L.t("|x-y|<=2 se escribe como dos: x-y<=2, y-x<=2.")
  L.t("Eventos en tabla: x>y, x+y<=3, abs(x-y)>=2, x<=9, y<=9.")
  L.h("TECLAS")
  L.t("Flechas arriba/abajo o tab: cambiar de campo.  Flechas izq/der: mover el cursor.")
  L.t("enter: resolver.  esc: regresar a los datos.  clear: borrar el campo.")
  L.t("En resultados: arriba/abajo recorren, izq/der saltan una pantalla, tab salta a la siguiente sección.")
  L.t("menu: Pestañas, Ejemplos (datos de tu serie) y Opciones (letra, símbolos).")
  L.h("LÍMITES DEL PROGRAMA")
  L.t("Densidades: sólo polinomios en x, y sobre regiones de rectas (como en tu serie). No acepta e^x ni regiones infinitas.")
  L.t("Si ves cuadritos en lugar de símbolos: menu > Opciones > Símbolos simples.")
end

-- ---------------------------------------------------------------------
-- 16. Pestanas, campos y ejemplos
-- ---------------------------------------------------------------------
local TOOLS = {
  {name = "1 Tabla discreta", solve = solveTabla,
   fields = {
     {k = "xs", l = "Valores de X", h = "Separados por coma. Ej: 0,1,2"},
     {k = "ys", l = "Valores de Y", h = "Separados por coma. Ej: 0,1,2"},
     {k = "ren", l = "Los renglones de tu tabla son (x o y)", h = "x si cada renglón es un valor de X; y si es de Y"},
     {k = "tab", l = "Celdas, renglón por renglón", h = "Ej: .1,.2,.2,.04,.08,.08,... Fracciones: 1/36"},
     {k = "ev", l = "Evento (opcional)", h = "Ej: x>y   x+y<=3   abs(x-y)>=2   x<=9, y<=9"},
     {k = "g", l = "g(x,y) para E[g] (opcional)", h = "Ej: x+y   abs(x-y)   120x+10"},
     {k = "cond", l = "Condición (opcional)", h = "y=1 da la condicional; x>=1 da P(evento | x>=1)"}},
   examples = {
     {n = "Ej. 3.3 Fábrica", v = {xs = "0,1,2", ys = "0,1,2", ren = "y",
       tab = ".10,.20,.20,.04,.08,.08,.06,.12,.12", ev = "x>y", g = "x+y", cond = "y=1"}},
     {n = "Serie 1 Supermercado", v = {xs = "0,1,2,3,4", ys = "0,1,2,3", ren = "x",
       tab = ".08,.07,.04,0,.06,.15,.05,.04,.05,.04,.10,.06,0,.03,.04,.07,0,.01,.05,.06",
       ev = "abs(x-y)>=2", g = "", cond = ""}},
     {n = "Serie 8 Restaurante", v = {xs = "7,9,10", ys = "7,9,10", ren = "x",
       tab = ".05,.05,.10,.05,.10,.35,0,.20,.10", ev = "x<=9, y<=9", g = "abs(x-y)", cond = "y=9"}},
     {n = "Serie 10 Transistores", v = {xs = "1,2,3", ys = "1,2,3", ren = "x",
       tab = ".3,.2,.1,.2,.1,0,.1,0,0", ev = "", g = "", cond = ""}},
     {n = "Autoexamen 10", v = {xs = "0,1", ys = "1,2", ren = "y", tab = ".1,.3,.4,.2", ev = "", g = "xy", cond = ""}}}},
  {name = "2 Densidad: k y P", solve = solveDensidad,
   fields = {
     {k = "f", l = "f(x,y)  (usa k para la constante)", h = "Ej: k(x+y)   24xy   kx   k(x^2+y^2)"},
     {k = "sop", l = "Soporte (donde f no es 0)", h = "Ej: 0<=x<=1, 0<=y<=1, x+y<=1"},
     {k = "ev", l = "Evento A (opcional)", h = "Ej: x+y<=1   x>1/2   1<=x<=3"},
     {k = "dado", l = "Dado B (opcional, para P(A|B))", h = "Ej: y<=1/2"}},
   examples = {
     {n = "Ej. 3.4", v = {f = "k(x+y)", sop = "0<=x<=1, 0<=y<=1", ev = "x+y<=1", dado = ""}},
     {n = "Serie 2 (banda)", v = {f = "kx", sop = "0<=x<=4, y>=0, y>=2-x, y<=4-x", ev = "1<=x<=3", dado = ""}},
     {n = "Serie 3 Tabacalera", v = {f = "24xy", sop = "x>=0, y>=0, x+y<=1", ev = "x>1/2", dado = ""}},
     {n = "Ej. 5.5 (P(A|B))", v = {f = "2", sop = "x>=0, y>=0, x+y<=1", ev = "x<=1/2", dado = "y<=1/2"}},
     {n = "Serie 7 Neumáticos", v = {f = "k(x^2+y^2)", sop = "20<=x<=30, 20<=y<=30", ev = "x-y<=2, y-x<=2", dado = ""}}}},
  {name = "3 Marginal y condicional", solve = solveMarg,
   fields = {
     {k = "f", l = "f(x,y)  (usa k para la constante)", h = "Ej: 24xy   x^3+kxy^2"},
     {k = "sop", l = "Soporte (donde f no es 0)", h = "Ej: x>=0, y>=0, x+y<=1"},
     {k = "dado3", l = "Valor conocido (opcional)", h = "Ej: y=3/4   x=1/2"},
     {k = "ev3", l = "Evento de la otra variable (opcional)", h = "Ej: x<1/8  (va con el valor conocido)"}},
   examples = {
     {n = "Serie 3 Tabacalera", v = {f = "24xy", sop = "x>=0, y>=0, x+y<=1", dado3 = "y=3/4", ev3 = "x<1/8"}},
     {n = "Ej. 3.6", v = {f = "x^3+kxy^2", sop = "0<=x<=1, 0<=y<=2", dado3 = "x=1/2", ev3 = "y<=1"}},
     {n = "Ej. 3.8", v = {f = "(8/3)x(x+y)", sop = "0<=y<=x<=1", dado3 = "", ev3 = ""}},
     {n = "Serie 6 Calcio", v = {f = "1/240", sop = "8.5<=x<=10.5, 120<=y<=240", dado3 = "", ev3 = ""}}}},
  {name = "4 E, Cov y regresión", solve = solveMomentos,
   fields = {
     {k = "f", l = "f(x,y)  (usa k para la constante)", h = "Ej: k(x^2+y^2)   2   24xy"},
     {k = "sop", l = "Soporte (donde f no es 0)", h = "Ej: 20<=x<=30, 20<=y<=30"},
     {k = "g4", l = "g(x,y) para E[g] (opcional)", h = "Ej: y-x   xy   x+y"}},
   examples = {
     {n = "Serie 9 Neumáticos", v = {f = "k(x^2+y^2)", sop = "20<=x<=30, 20<=y<=30", g4 = ""}},
     {n = "Serie 5 Queroseno", v = {f = "2", sop = "0<=x<=y<=1", g4 = "y-x"}},
     {n = "Ej. 3.9 Impurezas", v = {f = "2-2x", sop = "0<=x<=1, 0<=y<=1", g4 = "xy"}},
     {n = "Tabacalera", v = {f = "24xy", sop = "x>=0, y>=0, x+y<=1", g4 = ""}}}},
  {name = "5 Combinación lineal", solve = solveLineal,
   fields = {
     {k = "a", l = "Coeficientes de W = a1X1 + a2X2 + ... + c", h = "Ej: 2,-3   (uno por variable)"},
     {k = "c", l = "Constante c (vacío = 0)", h = "Ej: 7"},
     {k = "mu", l = "Medias E(X1), E(X2), ...", h = "Ej: 3,10"},
     {k = "tdis", l = "Te dan (v = Var, s = sigma, e = E(X^2))", h = "Escribe una letra: v, s o e"},
     {k = "dis", l = "Esos valores, en orden", h = "Ej: 25,164"},
     {k = "trel", l = "Relación (c = Cov, r = rho, i = indep.)", h = "Escribe una letra: c, r o i"},
     {k = "rel", l = "Valores de relación (12, 13, 23, ...)", h = "2 variables: un valor. 3 variables: tres"}},
   examples = {
     {n = "Serie 11 g y h", v = {a = "2,-3", c = "7", mu = "3,10", tdis = "e", dis = "25,164", trel = "i", rel = ""}},
     {n = "Ej. 3.13 (3 variables)", v = {a = "3,4,-6", c = "", mu = "2,-1,4", tdis = "v", dis = "4,6,8", trel = "c", rel = "1,-1,0"}},
     {n = "Autoexamen 8", v = {a = "2,-1", c = "", mu = "10,15", tdis = "v", dis = "3,4", trel = "c", rel = "2"}},
     {n = "Autoexamen 9", v = {a = "0.4,0.6", c = "", mu = "10,15", tdis = "s", dis = "15,20", trel = "r", rel = "-0.1"}}}},
  {name = "6 Integral doble", solve = solveIntegral,
   fields = {
     {k = "f6", l = "Función a integrar", h = "Ej: 24xy   x(x+y)"},
     {k = "ord", l = "Orden: dydx o dxdy", h = "dydx: adentro y, afuera x"},
     {k = "out6", l = "Límites de afuera: desde, hasta", h = "Números. Ej: 1/2,1"},
     {k = "in6", l = "Límites de adentro: desde, hasta", h = "Pueden llevar la otra letra. Ej: 0,1-x"}},
   examples = {
     {n = "Tabacalera P(X>1/2)", v = {f6 = "24xy", ord = "dydx", out6 = "1/2,1", in6 = "0,1-x"}},
     {n = "Queroseno E(Y-X)", v = {f6 = "2(y-x)", ord = "dxdy", out6 = "0,1", in6 = "0,y"}}}},
  {name = "7 Ayuda", solve = solveAyuda, fields = {}, examples = {}},
}

-- ---------------------------------------------------------------------
-- 17. Interfaz
-- ---------------------------------------------------------------------
local data = {ren = "x", tdis = "v", trel = "c", ord = "dydx"}
local tool, fsel, mode = 1, 1, "form"
local curpos = {}
local fscroll = 0
local outLines, wrapped, wrapW = nil, nil, 0
local oscroll = 0
local FS = 10
local C = {tinta = {22, 33, 62}, naranja = {207, 92, 54}, verde = {29, 122, 70},
           gris = {107, 114, 128}, papel = {246, 241, 231}, rojo = {178, 58, 72}, blanco = {255, 255, 255},
           negro = {0, 0, 0}, verdeclaro = {226, 241, 232}, marca = {255, 224, 138}, azulclaro = {220, 236, 235}}
local function col(gc, c) gc:setColorRGB(c[1], c[2], c[3]) end
local function uchars(s)
  local t = {}
  for ch in (s or ""):gmatch("[%z\1-\127\194-\244][\128-\191]*") do t[#t + 1] = ch end
  return t
end
local function invalidate() platform.window:invalidate() end
local function T() return TOOLS[tool] end
local function fieldKey() local fd = T().fields[fsel] return fd and fd.k end
local function getCur(k)
  if not curpos[k] then curpos[k] = #uchars(data[k]) end
  return curpos[k]
end

local registerMenu
local function runSolve()
  local L = newLog()
  local ok, err = pcall(T().solve, data, L)
  if not ok then
    L.e("No se pudo resolver:")
    L.e(tostring(err))
    L.n("Revisa los datos (esc) o consulta la pestaña 7 Ayuda.")
  end
  outLines = L.lines
  wrapped = nil
  oscroll = 0
  mode = "out"
  invalidate()
end
local function selectTool(i)
  tool = i
  fsel = 1
  fscroll = 0
  if #T().fields == 0 then runSolve() else mode = "form" end
  registerMenu()
  invalidate()
end
local function loadExample(ex)
  for k, v in pairs(ex.v) do data[k] = v curpos[k] = nil end
  mode = "form"
  invalidate()
end
registerMenu = function()
  if not toolpalette then return end
  local tabs = {"Pestañas"}
  for i, t in ipairs(TOOLS) do tabs[#tabs + 1] = {t.name, function() selectTool(i) end} end
  local ex = {"Ejemplos"}
  for _, e in ipairs(T().examples or {}) do ex[#ex + 1] = {e.n, function() loadExample(e) end} end
  if #ex == 1 then ex[2] = {"(sin ejemplos)", function() end} end
  local op = {"Opciones",
    {"Letra normal", function() FS = 10 wrapped = nil invalidate() end},
    {"Letra chica", function() FS = 9 wrapped = nil invalidate() end},
    {"Símbolos simples", function() SYM = SYM_A if mode == "out" then runSolve() end end},
    {"Símbolos normales", function() SYM = SYM_U if mode == "out" then runSolve() end end},
    {"Borrar datos de esta pestaña", function()
      for _, fd in ipairs(T().fields) do data[fd.k] = "" curpos[fd.k] = 0 end
      mode = "form" invalidate() end}}
  toolpalette.register({tabs, ex, op})
end

-- texto con desplazamiento horizontal para que el cursor siempre se vea
local function drawField(gc, fd, x, y, w, h, selected)
  col(gc, selected and C.blanco or {250, 250, 250})
  gc:fillRect(x, y, w, h)
  col(gc, selected and C.naranja or {190, 190, 190})
  gc:drawRect(x, y, w, h)
  if selected then gc:drawRect(x + 1, y + 1, w - 2, h - 2) end
  gc:setFont("sansserif", "r", 10)
  local s = data[fd.k] or ""
  local chars = uchars(s)
  local cp = selected and getCur(fd.k) or #chars
  local before = table.concat(chars, "", 1, cp)
  local bw = gc:getStringWidth(before)
  local off = 0
  if bw > w - 10 then off = bw - (w - 10) end
  gc:clipRect("set", x + 2, y + 1, w - 4, h - 2)
  col(gc, C.negro)
  gc:drawString(s, x + 4 - off, y + 1, "top")
  if selected then
    col(gc, C.naranja)
    gc:fillRect(x + 4 - off + bw, y + 3, 2, h - 6)
  end
  gc:clipRect("reset")
end

local function drawTop(gc, w, title)
  col(gc, C.tinta)
  gc:fillRect(0, 0, w, 19)
  col(gc, C.naranja)
  gc:fillRect(0, 0, 4, 19)
  col(gc, C.blanco)
  gc:setFont("sansserif", "b", 10)
  gc:drawString(title, 9, 1, "top")
end

local function drawForm(gc)
  local w, h = platform.window:width(), platform.window:height()
  drawTop(gc, w, T().name)
  local top, bottom = 21, h - 30
  local fh = 33
  local fields = T().fields
  local ysel = (fsel - 1) * fh
  if ysel - fscroll < 0 then fscroll = ysel end
  if ysel + fh - fscroll > bottom - top then fscroll = ysel + fh - (bottom - top) end
  gc:clipRect("set", 0, top, w, bottom - top)
  for i, fd in ipairs(fields) do
    local y = top + (i - 1) * fh - fscroll
    if y + fh > top and y < bottom then
      gc:setFont("sansserif", i == fsel and "b" or "r", 9)
      col(gc, i == fsel and C.tinta or C.gris)
      gc:drawString(i .. ". " .. fd.l, 6, y + 1, "top")
      gc:clipRect("set", 0, top, w, bottom - top)
      drawField(gc, fd, 6, y + 14, w - 12, 17, i == fsel)
      gc:clipRect("set", 0, top, w, bottom - top)
    end
  end
  gc:clipRect("reset")
  col(gc, C.papel)
  gc:fillRect(0, h - 29, w, 29)
  col(gc, C.naranja)
  gc:fillRect(0, h - 29, w, 1)
  local fd = fields[fsel]
  gc:setFont("sansserif", "r", 9)
  col(gc, C.tinta)
  if fd then gc:drawString(fd.h, 5, h - 28, "top") end
  gc:setFont("sansserif", "b", 9)
  col(gc, C.naranja)
  gc:drawString("enter: resolver    menu: pestañas y ejemplos", 5, h - 15, "top")
end

-- partir el texto en renglones que quepan
local function wrapText(gc, text, maxw)
  local out, line = {}, ""
  for word in text:gmatch("%S+") do
    local cand = (line == "") and word or (line .. " " .. word)
    if gc:getStringWidth(cand) <= maxw then
      line = cand
    else
      if line ~= "" then out[#out + 1] = line end
      if gc:getStringWidth(word) <= maxw then
        line = word
      else
        local chunk = ""
        for _, ch in ipairs(uchars(word)) do
          if gc:getStringWidth(chunk .. ch) > maxw then out[#out + 1] = chunk chunk = ch
          else chunk = chunk .. ch end
        end
        line = chunk
      end
    end
  end
  if line ~= "" or #out == 0 then out[#out + 1] = line end
  return out
end
local STYLE = {h = "b", s = "b", t = "r", r = "b", n = "i", e = "b"}
local function buildWrap(gc, w)
  local items = {}
  local maxw = w - 16
  for _, ln in ipairs(outLines or {}) do
    if ln.st == "g" then
      items[#items + 1] = {st = "g", rows = ln.rows, hl = ln.hl}
    else
      gc:setFont("sansserif", STYLE[ln.st], FS)
      local indent = (ln.st == "t" or ln.st == "n") and 4 or 0
      local parts = wrapText(gc, ln.tx, maxw - indent - 6)
      for i, p in ipairs(parts) do
        items[#items + 1] = {st = ln.st, tx = p, first = (i == 1), cont = (i > 1), indent = indent}
      end
    end
  end
  return items
end
local function lineH(gc)
  gc:setFont("sansserif", "r", FS)
  return gc:getStringHeight("Ag") + 1
end
local function gridDims(gc, it)
  gc:setFont("sansserif", "r", 9)
  local cw = {}
  for _, row in ipairs(it.rows) do
    for c, cell in ipairs(row) do
      local wv = gc:getStringWidth(cell) + 8
      if not cw[c] or wv > cw[c] then cw[c] = wv end
    end
  end
  local rh = gc:getStringHeight("Ag") + 2
  return cw, rh
end
local function itemH(gc, it, lh)
  if it.st == "g" then
    local _, rh = gridDims(gc, it)
    return #it.rows * rh + 6
  end
  if it.st == "h" and it.first then return lh + 6 end
  if it.st == "r" then return lh + 2 end
  return lh
end
local function drawGrid(gc, it, x, y, w)
  local cw, rh = gridDims(gc, it)
  gc:setFont("sansserif", "r", 9)
  local cx = {x}
  for c = 1, #cw do cx[c + 1] = cx[c] + cw[c] end
  for r, row in ipairs(it.rows) do
    local yy = y + (r - 1) * rh
    for c, cell in ipairs(row) do
      local bg = C.blanco
      if r == 1 then bg = C.tinta elseif c == 1 then bg = C.naranja end
      if it.hl[r .. "," .. c] then bg = C.marca end
      col(gc, bg)
      gc:fillRect(cx[c], yy, cw[c], rh)
      col(gc, {200, 200, 200})
      gc:drawRect(cx[c], yy, cw[c], rh)
      if r == 1 or (c == 1 and not it.hl[r .. "," .. c]) then col(gc, C.blanco) else col(gc, C.negro) end
      local sw = gc:getStringWidth(cell)
      gc:drawString(cell, math.floor(cx[c] + (cw[c] - sw) / 2), yy + 1, "top")
    end
  end
end
local function drawOut(gc)
  local w, h = platform.window:width(), platform.window:height()
  if not wrapped or wrapW ~= w then wrapped = buildWrap(gc, w) wrapW = w end
  drawTop(gc, w, #T().fields > 0 and (T().name .. "  " .. SYM.to .. " pasos") or T().name)
  local lh = lineH(gc)
  local top, bottom = 22, h - 14
  if oscroll > #wrapped - 1 then oscroll = math.max(0, #wrapped - 1) end
  local y = top
  gc:clipRect("set", 0, top, w, bottom - top)
  local i = oscroll + 1
  while i <= #wrapped and y < bottom do
    local it = wrapped[i]
    local ih = itemH(gc, it, lh)
    if it.st == "g" then
      drawGrid(gc, it, 8, y + 2, w)
    elseif it.st == "h" then
      if it.first then y = y + 3 end
      col(gc, C.tinta)
      gc:fillRect(2, y, w - 10, lh + 1)
      col(gc, C.blanco)
      gc:setFont("sansserif", "b", FS)
      gc:drawString(it.tx, 6, y, "top")
      ih = it.first and lh + 3 or lh
    elseif it.st == "r" then
      col(gc, C.verdeclaro)
      gc:fillRect(2, y, w - 10, lh + 1)
      col(gc, C.verde)
      gc:fillRect(2, y, 3, lh + 1)
      gc:setFont("sansserif", "b", FS)
      gc:drawString(it.tx, 8, y, "top")
    else
      local c = C.negro
      if it.st == "s" then c = C.naranja elseif it.st == "n" then c = C.gris elseif it.st == "e" then c = C.rojo end
      col(gc, c)
      gc:setFont("sansserif", STYLE[it.st], FS)
      local x = 4 + (it.indent or 0) + (it.cont and 8 or 0)
      gc:drawString(it.tx, x, y, "top")
    end
    y = y + ih
    i = i + 1
  end
  gc:clipRect("reset")
  -- barra de desplazamiento
  if #wrapped > 0 then
    local frac = oscroll / math.max(1, #wrapped - 1)
    col(gc, {225, 225, 225})
    gc:fillRect(w - 5, top, 4, bottom - top)
    col(gc, C.naranja)
    gc:fillRect(w - 5, math.floor(top + frac * (bottom - top - 16)), 4, 16)
  end
  col(gc, C.papel)
  gc:fillRect(0, h - 13, w, 13)
  gc:setFont("sansserif", "r", 7)
  col(gc, C.tinta)
  gc:drawString("arriba/abajo: mover   izq/der: página   tab: sección   esc: datos", 4, h - 12, "top")
end

function on.paint(gc)
  if mode == "form" and #T().fields > 0 then drawForm(gc) else drawOut(gc) end
end
local function pageSize()
  return math.max(3, math.floor((platform.window:height() - 40) / (FS + 5)))
end
local function insertText(str)
  local k = fieldKey()
  if not k then return end
  local chars = uchars(data[k])
  local cp = getCur(k)
  for _, ch in ipairs(uchars(str)) do
    table.insert(chars, cp + 1, ch)
    cp = cp + 1
  end
  data[k] = table.concat(chars)
  curpos[k] = cp
end
function on.charIn(ch)
  if mode == "form" then insertText(ch) invalidate() end
end
function on.backspaceKey()
  if mode ~= "form" then return end
  local k = fieldKey()
  if not k then return end
  local chars = uchars(data[k])
  local cp = getCur(k)
  if cp > 0 then
    table.remove(chars, cp)
    data[k] = table.concat(chars)
    curpos[k] = cp - 1
  end
  invalidate()
end
function on.clearKey()
  if mode ~= "form" then return end
  local k = fieldKey()
  if k then data[k] = "" curpos[k] = 0 end
  invalidate()
end
function on.arrowLeft()
  if mode == "form" then
    local k = fieldKey()
    if k then curpos[k] = math.max(0, getCur(k) - 1) end
  else
    oscroll = math.max(0, oscroll - pageSize())
  end
  invalidate()
end
function on.arrowRight()
  if mode == "form" then
    local k = fieldKey()
    if k then curpos[k] = math.min(#uchars(data[k]), getCur(k) + 1) end
  else
    oscroll = oscroll + pageSize()
    if wrapped then oscroll = math.min(math.max(0, #wrapped - 1), oscroll) end
  end
  invalidate()
end
function on.arrowUp()
  if mode == "form" then fsel = math.max(1, fsel - 1)
  else oscroll = math.max(0, oscroll - 1) end
  invalidate()
end
function on.arrowDown()
  if mode == "form" then fsel = math.min(#T().fields, fsel + 1)
  else
    oscroll = oscroll + 1
    if wrapped then oscroll = math.min(math.max(0, #wrapped - 1), oscroll) end
  end
  invalidate()
end
function on.tabKey()
  if mode == "form" then
    fsel = fsel % #T().fields + 1
  elseif wrapped then
    for i = oscroll + 2, #wrapped do
      if wrapped[i].st == "h" and wrapped[i].first then oscroll = i - 1 break end
    end
  end
  invalidate()
end
function on.backtabKey()
  if mode == "form" then
    fsel = (fsel - 2) % #T().fields + 1
  elseif wrapped then
    for i = oscroll, 1, -1 do
      if wrapped[i].st == "h" and wrapped[i].first then oscroll = i - 1 break end
    end
  end
  invalidate()
end
function on.enterKey()
  if mode == "form" then runSolve() end
end
function on.escapeKey()
  if mode == "out" and #T().fields > 0 then mode = "form" invalidate() end
end
function on.mouseDown(x, y)
  if mode ~= "form" then return end
  local i = math.floor((y - 21 + fscroll) / 33) + 1
  if i >= 1 and i <= #T().fields then fsel = i invalidate() end
end
function on.resize()
  wrapped = nil
  invalidate()
end
function on.save()
  return {data = data, tool = tool, fs = FS}
end
function on.restore(st)
  if type(st) == "table" and type(st.data) == "table" then
    data = st.data
    tool = tonumber(st.tool) or 1
    if tool < 1 or tool > #TOOLS then tool = 1 end
    FS = tonumber(st.fs) or 10
    curpos = {}
    registerMenu()
  end
end
function on.construction()
  registerMenu()
end
pcall(registerMenu)

-- acceso para pruebas fuera de la calculadora
if _G.__T3TEST then
  _G.__T3TEST.api = {TOOLS = TOOLS, data = data, newLog = newLog,
    select = selectTool, load = loadExample, solve = runSolve,
    state = function() return mode, tool, fsel, outLines end}
end
