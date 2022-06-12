-- inspired by goldenyoshi22#0101's master_doom mode, modified
-- section:       0  1  2  3  4   5  6  7  8  9   10 11 12 13 14  15 16 17 ROLL
local doom_lock={11,11,11,10,10, 10,10, 9, 9, 9,  9, 8, 8, 8, 8,  7, 7, 7, 7}
local doom_wait={ 5, 5, 5, 5, 5,  4, 4, 4, 4, 4,  4, 4, 4, 3, 3,  3, 3, 3, 4}
local doom_fall={10,10, 9, 9, 8,  8, 7, 7, 6, 6,  6, 5, 5, 5, 4,  4, 4, 3, 4}
local doom_das ={ 5, 5, 5, 5, 5,  5, 5, 4, 4, 4,  4, 4, 4, 3, 3,  3, 3, 2, 2}

local gc=love.graphics

local function drawTorikanText(D)
    if D.torikanTimer>=0 and D.torikanTimer<200 then            
        gc.setColor(1,1,0,1)
        mStr("EXCELLENT",300,200)
        if D.torikanTimer>120 then return end
        gc.setColor(1,1,1,1)
        mStr("but...",300,260)
        if D.torikanTimer>40 then return end
        mStr("let's go better",300,320)
        mStr("next time",300,370)
        if D.torikanTimer>0 then return end
        local diff=(D.torikanTime-D.torikanGoal)/60
        if     diff>=60 then gc.setColor(1,0,0,1)
        elseif diff>=45 then gc.setColor(1  ,0.2,0,1)
        elseif diff>=30 then gc.setColor(1  ,0.4,0,1)
        elseif diff>=20 then gc.setColor(1  ,0.6,0,1)
        elseif diff>=15 then gc.setColor(1  ,0.8,0,1)
        elseif diff>=10 then gc.setColor(1  ,1,  0,1)
        elseif diff>=5  then gc.setColor((love.timer.getTime()%0.1)<0.05 and 1 or 0.5,1,  0,1)
        else                 gc.setColor((love.timer.getTime()%0.04)<0.02 and 1 or 0.2,1,  0,1) end
        mStr(STRING.time(D.torikanTime/60).." / "..STRING.time(D.torikanGoal/60).."\n(+"..diff.."s)",300,480)
    end
end

local function slowClear(P) -- gimmick where lines are only cleared every 20 levels
    local D=P.modeData
    local l=D.pt
    -- if (l<1300 or l>1799) or l%100==99 then
    --     P.gameEnv.fillClear=true
    --     P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
    --     return
    -- end
    P.gameEnv.fillClear=false
    if math.floor(D.pt/10)>math.floor(D.prev_pt/10) then --check if 20 levels have passed
        P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
    elseif #P.field>=11 then
        local _r,_g=P:clearFilledLines(11,#P.field-11)
        local _c=_r+_g
        if _c>0 then P:clearFilledLines(11,#P.field-11) end
        return _c
    end
end

local function getGimmick(lvl)
    if lvl<500 then return ""
    elseif lvl<1000 then return "- Garbage"
    elseif lvl<1200 then return "- Bone"
    elseif lvl<1300 then return "- Bone\n- Garbage"
    elseif lvl<1400 then return "- Bone\n- Freeze"
    elseif lvl<1500 then return "- Bone\n- Garbage\n- Fading"
    elseif lvl<1600 then return "- Bone\n- Garbage\n- Slow Invis"
    elseif lvl<1700 then return "- Bone\n- Garbage\n- Medium Invis"
    elseif lvl<1800 then return "- Bone\n- Garbage\n- Fast Invis"
    else return "- Bone\n- Big\n- Instant Invis"end
end

local function sendGarbage(P)
    if P.cur then return end
    local arr=LINE.new(0)
    if #P.field>0 then
        for i=1,#P.field[1] do
            arr[i]=P.field[1][i]
        end
    else return end
    for i=1,#arr do arr[i]=arr[i]>0 and 20 or 0 end -- set everything to either 21 or 0
    table.insert(P.field,1,arr)
    table.insert(P.visTime,1,LINE.new(20))
    P.fieldBeneath=P.fieldBeneath+30
    P.modeData.sendGarbage=false
end

return{
    drop=0,
    lock=doom_lock[1],
    wait=doom_wait[1],
    fall=doom_fall[1],
    noTele=true,
    das=doom_das[1],arr=1,
    mesDisp=function(P)
        D=P.modeData
        PLY.draw.drawProgress(D.pt,D.target)
        drawTorikanText(D)
        gc.setColor(1,1,1,1)
        setFont(20)
        mStr(getGimmick(D.pt),700,0)
    end,
    hook_drop=function(P)
        local D=P.modeData
        D.prev_pt=D.pt
        -- D.sendGarbage=true
        local c=#P.clearedRow
        local s,_c=nil
        if c==0 and D.pt%100==99 then
            _c=slowClear(P)
            if _c~=nil and _c>0 then goto calc_frozen_lines end
            return
        end
        s=c<3 and c+1 or c==3 and 5 or 7
        if P.combo>7 then s=s+2
        elseif P.combo>3 then s=s+1
        end
        D.pt=math.min(D.pt+s,1800)

        _c=slowClear(P)
        ::calc_frozen_lines::
        if _c==nil then goto skip_frozen_lines end
        s=_c<3 and _c+1 or _c==3 and 5 or 7
        D.pt=math.min(D.pt+s,1800)
        ::skip_frozen_lines::

        if D.pt%100==99 and not D.rollStarted then
            SFX.play('warn_1')
        elseif D.pt>=D.target and not D.rollStarted then--Level up!
            s=D.target/100
            local E=P.gameEnv
            E.lock=doom_lock[s]
            E.wait=doom_wait[s]
            E.fall=doom_fall[s]
            if E.das~=doom_das[s] then E.das=doom_das[s] end

            if s==2 then BG.set('rainbow')
            elseif s==4 then BG.set('rainbow2')
            elseif s==5 then
                if P.stat.frame>135*60 then -- torikan: 2min 15s
                    D.pt=500
                    P.waiting=1e99
                    D.torikanTimer=300
                    D.torikanGoal=135*60
                    D.torikanTime=P.stat.frame
                    BGM.stop()
                    return
                else
                    P.gameEnv.freshLimit=9
                    BG.set('glow')
                    BGM.play('secret7th remix')
                end
            elseif s==6 then BG.set('lightning')
            elseif s==10 then 
                if P.stat.frame>285*60 then -- torikan: 4min 30s
                    D.pt=1000
                    P.waiting=1e99
                    D.torikanTimer=300
                    D.torikanGoal=285*60
                    D.torikanTime=P.stat.frame
                    BGM.stop()
                    return
                end
                E.bone=true
            elseif s==15 then 
                if P.stat.frame>405*60 then -- torikan: 6min 45s
                    D.pt=1000
                    P.waiting=1e99
                    D.torikanTimer=300
                    D.torikanGoal=405*60
                    D.torikanTime=P.stat.frame
                    BGM.stop()
                    return
                end
                P:setInvisible(150)
            elseif s==16 then P:setInvisible(50)
            elseif s==17 then P:setInvisible(15)
            elseif s==18 then 
                P:setInvisible(0)
                D.rollStarted=true
                P.waiting=300
            end
            D.target=D.target+100
            P:stageComplete(s)
            SFX.play('reach')
        end
    end,
    task=function(P)
        D=P.modeData
        P:set20G(true)
        D.pt=0
        D.pt=0
        D.target=100
        D.torikanTimer=-1
        D.rollStarted=false
        D.rollTransTimer=300
        while true do
            YIELD()
            
            if D.torikanTimer>=0 then
                for y=1,#P.field do for x=1,10 do
                    P.visTime[y][x]=D.torikanTimer-240
                end end
                D.torikanTimer=D.torikanTimer>0 and math.max(D.torikanTimer-1,0) or D.torikanTimer
            end
            if D.torikanTimer==0 then P:win('finish') return end


            if D.rollTransTimer>=0 and D.rollStarted then
                D.rollTransTimer=D.rollTransTimer-1
            end
            if D.rollTransTimer<300 then
                for y=1,#P.field do for x=1,10 do
                    P.visTime[y][x]=D.rollTransTimer-240
                end end
            end
            if D.rollTransTimer==240 then 
                TABLE.cut(P.field)
                TABLE.cut(P.visTime)
            elseif D.rollTransTimer==180 then
                playReadySFX(3,3)
                P:_showText("3",0,-120,120,'fly',1)
            elseif D.rollTransTimer==120 then
                playReadySFX(2,2)
                P:_showText("2",0,-120,120,'fly',1)
            elseif D.rollTransTimer==60 then
                playReadySFX(1,1)
                P:_showText("1",0,-120,120,'fly',1)
            elseif D.rollTransTimer==0 then
                playReadySFX(0,1)
            end

            if D.sendGarbage then sendGarbage(P) end
        end
    end,
}
