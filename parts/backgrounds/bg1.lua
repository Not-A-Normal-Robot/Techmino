--Horizonal red-blue gradient
local gc=love.graphics
local back={}
local shader=SHADER.grad1

local t
function back.init()
    t=math.random()*260
end
function back.update(dt)
    t=(t+dt)%2600
end
function back.draw()
    gc.clear(.08,.08,.084)
    shader:send('phase',t)
    gc.setShader(shader)
    gc.rectangle('fill',0,0,SCR.w,SCR.h)
    gc.setShader()
end
return back
