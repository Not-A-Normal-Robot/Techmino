--[[
    DOS/CMD background
    special chars:
    { = start instant-type
    } = end instant-type

    BG.send(mode,args)

    "levelUp" mode:
        args = table {drop,lock,wait,fall,hang,hurry,das,arr,garb,bone}
            - elements can be nil

    "input" mode:
        args = string, will be inputted into background
--]]
local gc=love.graphics
local gc_setColor,gc_clear,gc_print,gc_rect=gc.setColor,gc.clear,gc.print,gc.rectangle
local back={}
local text
local pending
local pending2
local t
local totalT
local initPhase
local cursorX,cursorY
local start
local function getCursorPos()
    local lastNewLinePos=0
    while true do
        local n=string.find(text,'\n',lastNewLinePos+1)
        if n==nil then break else lastNewLinePos=n end
    end
    local _,y=string.gsub(text,'\n','\n')
    local x=#text-lastNewLinePos
    return x,y
end
local function pushToMain()
    local s
    local prevPending=pending
    s=string.sub(pending,1,1)
    pending=string.sub(pending,2)
    if s=='{'then -- Instant push multiple chars
        local i=string.find(pending,'}')
        if not i then
            print("Could not find closing bracket in text:\n"..prevPending)
            error("Could not find closing bracket in text (logged in debug console)")
        end
        s=string.sub(pending,1,i-1)
        pending=pending:sub(i+1)
    end
    text=text..s
    if select(2,string.gsub(text,'\n','\n'))>20 then text=text:sub(string.find(text,'\n')+1)end -- Delete old lines
    cursorX,cursorY=getCursorPos()
end
function back.init()
    text=""
    pending=""
    cursorX,cursorY=getCursorPos()
    t,totalT=0,0
    initPhase=0
    start=(
        SYSTEM=='Windows'and'C:\\>'or
        SYSTEM=='macOS'and'$ 'or
        SYSTEM=='Linux'and'root@TECHMINO:~# 'or
        '> ')
    back.event('levelUp',{0,7,3,3,5,1e99,3,1,7,3})
end
function back.update(dt)
    t,totalT=t+dt,totalT+dt

    -- Console Init Phase
    if initPhase==0 and totalT>2 then
        initPhase=1
        text="Techmino Console "..VERSION.string.."\n"..SYSTEM.." edition\nCopyright 2019-2022 26F-Studio. Some rights reserved."
        cursorX,cursorY=getCursorPos()
    end
    if initPhase==1 and totalT>3 then
        initPhase=2
        text=text.."\n\n"..start
        cursorX,cursorY=getCursorPos()
    end

    local p=#pending
    local typeDelay=
    (
        p<20 and 0.1 or
        p<60 and 0.07 or
        p<120 and 0.05 or 0.04
    )
    -- "Type" pending text to screen
    if t>typeDelay and initPhase==2 and #pending>0 then
        t=0
        pushToMain()
    end
end
function back.draw()
    gc_clear(0,0,0)
    gc_setColor(0,1,0)
    FONT.set(28,'mono')
    gc_print(text,0,0)
    if t%1<.5 then gc_rect('fill',17*cursorX,35*(cursorY+.8),17,4)end
end
function back.event(mode,args)
    if mode=='levelUp' then
        if args[1] then pending=pending.."setDrop("..args[1].."){\nDrop delay set to "..args[1].." frames.\n\n"..start.."}"end
        if args[2] then pending=pending.."setLock("..args[2].."){\nLock delay set to "..args[2].." frames.\n\n"..start.."}"end
        if args[3] then pending=pending.."setWait("..args[3].."){\nEntry delay set to "..args[3].." frames.\n\n"..start.."}"end
        if args[4] then pending=pending.."setFall("..args[4].."){\nLine delay set to "..args[4].." frames.\n\n"..start.."}"end
        if args[5] then pending=pending.."setHang("..args[5].."){\nDeath delay set to "..args[5].." frames.\n\n"..start.."}"end
        if args[6] then pending=pending.."setHurry("..args[6].."){\nARE interruption set to "..args[6].." frames.\n\n"..start.."}"end
        if args[7] then pending=pending.."setDAS("..args[7].."){\nDAS set to "..args[7].." frames.\n\n"..start.."}"end
        if args[8] then pending=pending.."setARR("..args[8].."){\nARR set to "..args[8].." frames.\n\n"..start.."}"end
        if args[9] then pending=pending.."setGarb("..args[8].."){\nGarbage spawn rate set to "..args[9].." pieces.\n\n"..start.."}"end
        if args[10]then pending=pending.."setBone("..args[10].."){\nBone level set to "..args[10]..".\n\n"..start.."}"end
    elseif mode=='input' then
        pending=pending..args
    end
end
return back
