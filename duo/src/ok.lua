-- vim: tabstop=2:softtabstop=2:shiftwidth=2:expandtab
--------- --------- --------- --------- --------- --------- 
require "config"

function rogues(    ignore)
  ignore = {jit=true, utf8=true, math=true, package=true, 
            table=true, coroutine=true, bit=true, os=true, 
            io=true, bit32=true, string=true, arg=true, 
            debug=true, _VERSION=true, _G=true }
  for k,v in pairs( _G ) do
   if type(v) ~= "function" and not ignore[k] then
    if k:match("^[^A-Z]") then
     print("-- warning, rogue local ["..k.."]") end end end 
end 

function off(t) return t end

function okReport( x)
  x = (Lean.ok.tries-Lean.ok.fails)/ (Lean.ok.tries+10^-64)
  return math.floor(0.5 + 100*(1- x)) end

function ok(t,  n,score,      passed,err,s)
  for x,f in pairs(t) do
    Lean.ok.tries = Lean.ok.tries + 1
    print("-- Test #" .. Lean.ok.tries .. 
          " (oops=".. okReport() .."%). Checking ".. x .."... ")
    local y,n = Lean.ok.tries, Lean.ok.fails
    Lean = Lean0()
    Lean.ok.tries = Lean.ok.tries+ y
    Lean.ok.fails = Lean.ok.fails+ n
    passed,err = pcall(f)
    if not passed then
      Lean.ok.fails = Lean.ok.fails + 1
      print("-- E> Failure " .. Lean.ok.fails .. " of " 
            .. Lean.ok.tries ..": ".. err) end end
  rogues()
end
