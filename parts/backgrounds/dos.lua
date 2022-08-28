--[[
    DOS/CMD background
    special chars:
    { = start instant-type
    } = end instant-type

    BG.send(mode,args)

    "levelUp" mode:
        args = table {drop,lock,wait,fall,hang,hurry,das,arr,garb,bone}
            - elements can be nil

    "die" mode:


    "input" mode:
        args = string, will be inputted into background
--]]
local gc=love.graphics
local gc_setColor,gc_clear,gc_print,gc_rect=gc.setColor,gc.clear,gc.print,gc.rectangle
local back={}
local curTxt,pending -- currently displayed curTxt; curTxt in buffer
local cursorX,cursorY -- blinking _ position
local start -- starting line (e.g. "C:\>")

local typeDelay -- delay per letter
local t -- time since last letter was typed
local totalT -- time since bg init
local initPhase -- init phase ("Techmino Console")

local state
--[[
    norm: normal
    dead: player died, credits not yet
    cred: 60s after death
]]
local timeSinceDeath

local function getCursorPos()
    local lastNewLinePos=0
    while true do
        local n=string.find(curTxt,'\n',lastNewLinePos+1)
        if n==nil then break else lastNewLinePos=n end
    end
    local _,y=string.gsub(curTxt,'\n','\n')
    local x=#curTxt-lastNewLinePos
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
            print("Could not find closing bracket in curTxt:\n"..prevPending)
            error("Could not find closing bracket in curTxt (logged in debug console)")
        end
        s=string.sub(pending,1,i-1)
        pending=pending:sub(i+1)
    elseif s=='~'then return end
    t=0

    curTxt=curTxt..s
    local l=select(2,string.gsub(curTxt,'\n','\n'))
    for i=1,l-19 do curTxt=curTxt:sub(string.find(curTxt,'\n')+1)end -- Delete old lines
    cursorX,cursorY=getCursorPos()
end
function back.init()
    curTxt=""
    pending=""
    cursorX,cursorY=getCursorPos()
    t,totalT,typeDelay=0,0,0.1
    initPhase=0
    start=(
        SYSTEM=='Windows'and'C:\\>'or
        SYSTEM=='macOS'and'$ 'or
        SYSTEM=='Linux'and'root@TECHMINO:~# 'or
        '> ')
    state='norm'
    timeSinceDeath=0
    back.event('levelUp',{0,7,3,3,5,1e99,3,1,7,3})
end
function back.update(dt)
    t,totalT=t+dt,totalT+dt
    if state=='dead'then timeSinceDeath=timeSinceDeath+dt end
    if state=='dead'and timeSinceDeath>=10 then
        state='cred'
        pending=pending.."credits{\n\n}{Techmino\n}"
        for i=1,#text.staff do pending=pending..'{'..text.staff[i]..'\n}'end
        typeDelay=1
    end

    -- Console Init Phase
    if initPhase==0 and totalT>2 then
        initPhase=1
        curTxt="Techmino Console "..VERSION.string.."\n"..SYSTEM.." edition\nCopyright 2019-2022 26F-Studio. Some rights reserved."
        cursorX,cursorY=getCursorPos()
    end
    if initPhase==1 and totalT>3 then
        initPhase=2
        curTxt=curTxt.."\n\n"..start
        cursorX,cursorY=getCursorPos()
    end
    -- "Type" pending curTxt to screen
    if t>typeDelay and initPhase==2 and #pending>0 then
        pushToMain()
    end
end
function back.draw()
    gc_clear(0,0,0)
    gc_setColor(0,1,0,(state=='dead'or state=='cred')and .7 or .4)
    FONT.set(28,'mono')
    gc_print(curTxt,0,0)
    if t%1<.5 then gc_rect('fill',17*cursorX,35*(cursorY+.8),17,4)end
end
function back.event(mode,args)
    if mode=='set'then
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
    elseif mode=='levelUp'then
        pending=pending.."levelUp("..args[1].."){\nLevel Up!\n"
        if args[2] then pending=pending.."Drop delay set to "..args[2].." frames.\n"end
        if args[3] then pending=pending.."Lock delay set to "..args[3].." frames.\n"end
        if args[4] then pending=pending.."Entry delay set to "..args[4].." frames.\n"end
        if args[5] then pending=pending.."Line delay set to "..args[5].." frames.\n"end
        if args[6] then pending=pending.."Death delay set to "..args[6].." frames.\n"end
        if args[7] then pending=pending.."ARE Interruption set to "..args[7].." frames.\n"end
        if args[8] then pending=pending.."DAS set to "..args[8].." frames.\n"end
        if args[9] then pending=pending.."ARR set to "..args[9].." frames.\n"end
        if args[10]then pending=pending.."Garbage spawn rate set to "..args[10].." frames.\n"end
        if args[11]then pending=pending.."Bone level set to "..args[11].." frames.\n"end
        pending=pending.."\n"..start.."}"
    elseif mode=='die'then
        state='dead'
    elseif mode=='input'then
        pending=pending..args
    elseif mode=='clear'then
        curTxt=start
    end
    local p=#pending
    typeDelay=
    (
        p<20 and 0.1 or
        p<60 and 0.07 or
        p<120 and 0.05 or 0.04
    )
end
return back
