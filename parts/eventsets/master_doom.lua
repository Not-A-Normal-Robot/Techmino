-- inspired by goldenyoshi22#0101's master_doom mode
-------------------------<LOCAL VARIABLES>-------------------------
-- section:        0   1   2   3   4   5  6  7  8  9  10 11 12 13 14  15 16 17 ROLL
local doom_lock={ 11, 11, 11, 10, 10, 10,10, 9, 9, 9,  9, 8, 8, 8, 8,  7, 7, 7,  7}
local doom_wait={  5,  5,  5,  5,  5,  4, 4, 4, 4, 4,  4, 4, 4, 3, 3,  3, 3, 3,  3}
local doom_fall={ 10, 10,  9,  9,  8,  8, 7, 6, 6, 5,  4, 4, 3, 3, 2,  2, 1, 0,  0}
local doom_das ={  5,  5,  5,  5,  5,  5, 5, 4, 4, 4,  4, 4, 4, 3, 3,  3, 3, 3,  3}
local doom_garb={nil,nil,nil,nil,nil, 20,18,16,14,12, 11,10, 9, 9, 8,  8, 8, 7,nil}

local gc=love.graphics
local gc_translate,gc_rotate,gc_push,gc_pop=gc.translate,gc.rotate,gc.push,gc.pop
local gc_stencil,gc_rectangle,gc_scale=gc.stencil,gc.rectangle,gc.scale
local gc_setColor,gc_setStencilTest=gc.setColor,gc.setStencilTest
local gc_draw,gc_print=gc.draw,gc.print

local border=GC.DO{334,620,
    {'setLW',2},
    {'dRect',16,1,302,618}
}
local drawFrames=0

-------------------------</LOCAL VARIABLES>-------------------------
-------------------------<LOCAL FUNCTIONS>-------------------------

local function _boardTransform(mode)
    if mode then
        if mode=="U-D"then
            gc_translate(0,590)
            gc_scale(1,-1)
        elseif mode=="L-R"then
            gc_translate(300,0)
            gc_scale(-1,1)
        elseif mode=="180"then
            gc_translate(300,590)
            gc_scale(-1,-1)
        end
    end
end
local function _stencilBoard()gc_rectangle('fill',0,-10,300,610)end
local function _applyField(P)
    gc_push('transform')

    --Apply shaking
    if P.shakeTimer>0 then
        local dx=math.floor(P.shakeTimer/2)
        local dy=math.floor(P.shakeTimer/3)
        gc_translate(dx^1.6*(dx%2*2-1)*(P.gameEnv.shakeFX+1)/30,dy^1.4*(dy%2*2-1)*(P.gameEnv.shakeFX+1)/30)
    end

    --Apply swingOffset
    local O=P.swingOffset
    if P.gameEnv.shakeFX then
        local k=P.gameEnv.shakeFX
        gc_translate(O.x*k+150+150,O.y*k+300)
        gc_rotate(O.a*k)
        gc_translate(-150,-300)
    else
        gc_translate(150,0)
    end

    --Apply stencil
    gc_stencil(_stencilBoard)
    gc_setStencilTest('equal',1)

    --Move camera
    gc_push('transform')
    _boardTransform(P.gameEnv.flipBoard)
    gc_translate(0,P.fieldBeneath+P.fieldUp)
end

local function getSection(lvl) return lvl==1799 and 19 or math.floor(lvl/100)+1 end

local function sendGarbage(P)
    SFX.play('warn_1')
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
    P.modeData.garbageCounter=0
end

local function drawGarbageMeter(P,fill,color)
    if not fill then return
    elseif fill<=0 then return end

    local f=600*math.min(fill,1)
    _applyField(P)
    gc_setStencilTest()
    gc_setColor(color and color or COLOR.Z)
    gc_rectangle('fill',303,600-f,11,f,2)
    gc_pop()
    gc_pop()
end

-------------------------<ULTRABONE LOCAL FUNCTIONS>-------------------------
local ultraBone={}
ultraBone.bone=GC.DO{30,30,
    -- left/right vertical line
    {'fRect',3,6,4,20},
    {'fRect',23,6,4,20},

    -- top horizontal lines
    {'fRect',7,6,5,2},
    {'fRect',18,6,5,2},

    -- bottom horizontal lines
    {'fRect',7,24,5,2},
    {'fRect',18,24,5,2},
}
ultraBone.drawBlock=function(x,y)gc.draw(ultraBone.bone,30*x+120,30*y)end
ultraBone.drawActive=function(UB,CB,curX,curY) -- UltraBone, Current Block, P.curX, P.curY
    if UB==1 then
        for i=1,#CB do for j=1,#CB[1]do
            if CB[i][j]then gc_draw(ultraBone.bone,30*(j+curX-1)-30,-30*(i+curY-1))end
        end end
    else
        for i=1,#CB do for j=1,#CB[1] do
            if CB[i][j] then
                local x,y=30*(curX+j)+120,30*(19-i+curY)
                -- Up border
                if not (CB[i+1]and CB[i+1][j]) then gc_rectangle("fill",x,y+30,30,2) end
                -- Left border
                if not (CB[i][j-1]and CB[i][j-1]) then gc_rectangle("fill",x,y+30,2,30) end
                -- Right border
                if not (CB[i][j+1]and CB[i][j+1]) then gc_rectangle("fill",x+28,y+30,2,30) end
                -- Down border
                if not (CB[i-1]and CB[i-1][j]) then gc_rectangle("fill",x,y+60,30,2) end
            end
        end end
    end
end
ultraBone.drawXs=function(B,fieldH,fieldBeneath,hold)
    gc_setColor(0,1,0,(hold and .3 or .8))
    local y=math.floor(fieldH+1-math.modf(B.RS.centerPos[B.id][B.dir][1]))+math.ceil(fieldBeneath/30)+(hold and .14 or 0)
    B=B.bk
    local x=math.floor(6-#B[1]*.5)
    local cross=TEXTURE.puzzleMark[-1]
    for i=1,#B do for j=1,#B[1]do
        if B[i][j]then
            gc_draw(cross,30*(x+j-2),30*(1-y-i))
        end
    end end
end
ultraBone.drawLvl=function(s1,s2)
    FONT.set(40,'mono')
    mStr(s1,62,322)
    mStr(s2,62,376)
    gc_rectangle('fill',15,375,90,4)
end
ultraBone.drawMisc=function(P)
    local D=P.modeData
    -- time
    FONT.set(25,'mono')
    local tm=STRING.time(P.stat.time)
    gc_print(tm,20,540)

    -- score
    gc_print(math.ceil(P.score1),18,509)

    -- finesse counter
    if P.finesseCombo>2 then
        local S=P.stat
        local str=P.finesseCombo.."x"
        if S.finesseRate==5*S.piece then gc_setColor(1,0,0)
        elseif S.maxFinesseCombo==S.piece then gc_setColor(1,1,0)
        else gc_setColor(0,1,0)end
        gc_print(str,20,570)
    end
    gc_setColor(0,1,0,1)

    -- Lock Delay Bar & Lock Delay Reset Counter
    if P.cur and P.lockDelay and P.lockDelay>0 then gc_rectangle('fill',150,600,300*(P.lockDelay/P.gameEnv.lock),6) end
    for i=1,math.min(P.freshTime,15) do
        gc_rectangle('fill',130+20*i,615,14,5)
    end

    -- B2B Bar
    gc_rectangle('fill',135,600-P.b2b*.6,11,P.b2b*.6)

    -- Garbage Bar
    local g=doom_garb[getSection(D.pt)]
    if g then
        local c=D.garbageCounter
        if c>0 then gc_rectangle('fill',450,600-c/g*600,11,c/g*600) end
    elseif D.rollTransTimer<300 then
        local r=D.rollStartTime -- [R]oll start time
        local e=r+60 -- [E]nd of roll
        local t=P.stat.time -- current [T]ime
        if e>t then
            local p=1-(t-r)/(e-r)
            gc_rectangle('fill',450,600-p*600,11,p*600)
        end
    end

    ultraBone.drawSpeed(499,505,P.dropSpeed)
    FONT.set(30,'mono')
    mStr(P.username,300,-60)
end
ultraBone.drawSpeed=function(x,y,speed)
    local needle=GC.DO{30,9,{'fRect',5,3,21,3}}
    gc_setColor(0,1,0,1)
    gc_draw(TEXTURE.dial.frame,x,y)
    gc_draw(needle,x+40,y+40,2.094+(speed<=175 and .02094*speed or 4.712-52.36/(speed-125)),nil,nil,1,1)
    FONT.set(30,'mono')mStr(math.floor(speed),x+40,y+19)
end
ultraBone.drawRoll=function(P)
    local D=P.modeData
    FONT.set(50,'mono')
    if D.rollTransTimer<300 and D.rollTransTimer>0 then
        if D.rollTransTimer<180 and D.rollTransTimer>=120 then mStr("3",300,150)
        elseif D.rollTransTimer<120 and D.rollTransTimer>=60 then mStr("2",300,150)
        elseif D.rollTransTimer<60 and D.rollTransTimer>=0 then mStr("1",300,150)
        end
    end
    gc.rectangle('line',0,240,126,80)
    FONT.set(45,'mono')
    local T=D.rollStartTime+60-P.stat.time
    mStr((T<10 and "%.2f" or "%.1f"):format(math.max(T,0)),65,250)
end
ultraBone.draw=function(P,repMode)
    local D=P.modeData
    local UB=D.ultraBone
    local function stencil()gc_rectangle('fill',150,-10,300,610) end
    gc_stencil(stencil)
    gc_setStencilTest('equal',1)
    local F=P.field
    if UB==1 then
        for i=1,#F do for j=1,#F[i] do
            if F[i][j]~=0 then
                gc_setColor(0,1,0,P.visTime[i][j]*0.05)
                if repMode and P.visTime[i][j]<1 then gc_setColor(.4,.4,.4,1)end
                ultraBone.drawBlock(j,20-i)
            end
        end end
    else
        local BF={}
        for i=1,#F do
            BF[i]={}
            for j=1,#F[i]do
                BF[i][j]=F[i][j]
            end
        end
        if P.cur then
            local B=P.cur.bk
            for i=1,#B do for j=1,#B[1] do
                if B[i][j] then
                    if not BF[i+P.curY-1] then BF[i+P.curY-1]={0,0,0,0,0,0,0,0,0,0} end
                    BF[i+P.curY-1][j+P.curX-1]=626
                end
            end end
        end
        for i=1,#BF do for j=1,#BF[i] do
            if BF[i][j]~=0 then
                gc_setColor(0,1,0,BF[i][j]==626 and 1 or P.visTime[i][j]*0.05)
                if repMode and BF[i][j]~=626 and P.visTime[i][j]<1 then gc_setColor(.4,.4,.4,1)end
                local x,y=30*j+120,30*(19-i)
                -- Up border
                if i+1>#BF or BF[i+1][j]==0 then gc_rectangle("fill",x,y+30,30,2) end
                -- Left border
                if j<2 or BF[i][j-1]==0 then gc_rectangle("fill",x,y+30,2,30) end
                -- Right border
                if j>9 or BF[i][j+1]==0 then gc_rectangle("fill",x+28,y+30,2,30) end
                -- Down border
                if i<2 or BF[i-1][j]==0 then gc_rectangle("fill",x,y+60,30,2) end
            end
        end end
    end
    gc_setColor(0,1,0,1)
    gc_push('transform')
        gc_translate(150,600)
        if P.cur and UB==1 then ultraBone.drawActive(UB,P.cur.bk,P.curX,P.curY) end
        ultraBone.drawXs(P.nextQueue[1],P.gameEnv.fieldH,P.fieldBeneath,false)
        local h=P.holdQueue[1]
        if h then ultraBone.drawXs(h,P.gameEnv.fieldH,P.fieldBeneath,true) end
        gc_setStencilTest()
        gc_setColor(0,1,0,1)
        if UB==1 then
            if h then ultraBone.drawActive(UB,h.bk,-4,19)end
            for i=1,P.gameEnv.nextCount do ultraBone.drawActive(UB,P.nextQueue[i].bk,12,23-3*i)end
        end
    gc_pop()
    if UB~=1 then
        if h and not (D.hideHold and not (P.result=='win' or P.result=='lose' or repMode)) then
            if D.hideHold then gc_setColor(.6,.6,.6) end
            ultraBone.drawActive(UB,h.bk,-5,-18)
            if D.hideHold then gc_setColor(0,1,0) end
        elseif h then
            FONT.set(62,'mono')
            mStr("?",62,0)
        end
        for i=1,P.gameEnv.nextCount do ultraBone.drawActive(UB,P.nextQueue[i].bk,11,3*i-22)end
    end
    if D.rollStarted then ultraBone.drawRoll(P)
    else ultraBone.drawLvl(D.pt,D.target)end
    ultraBone.drawMisc(P)
end
-------------------------</ULTRABONE LOCAL FUNCTIONS>-------------------------
-------------------------<EVENTSET>-------------------------

return{
    drop=0,
    lock=doom_lock[1],
    wait=doom_wait[1],
    fall=doom_fall[1],
    noTele=true,
    das=doom_das[1],arr=1,
    mesDisp=function(P,repMode)
        D=P.modeData
        if D.ultraBone then
            gc_push('transform')
            gc_translate(P.x,P.y)
            goto skip_ultraBone
        end
        PLY.draw.drawProgress(D.pt,D.target)

        -- draw torikan text
        if D.torikanTimer>=0 and D.torikanTimer<200 then
            gc_setColor(1,1,0,1)
            mStr("EXCELLENT",300,200)
            if D.torikanTimer>120 then return end
            gc_setColor(1,1,1,1)
            mStr("but...",300,260)
            if D.torikanTimer>40 then return end
            mStr("let's go better",300,320)
            mStr("next time",300,370)
            if D.torikanTimer>0 then return end
            local diff=(D.torikanTime-D.torikanGoal)/60
            if     diff>=60 then gc_setColor(1,0,0,1)
            elseif diff>=45 then gc_setColor(1  ,0.2,0,1)
            elseif diff>=30 then gc_setColor(1  ,0.4,0,1)
            elseif diff>=20 then gc_setColor(1  ,0.6,0,1)
            elseif diff>=15 then gc_setColor(1  ,0.8,0,1)
            elseif diff>=10 then gc_setColor(1  ,1,  0,1)
            elseif diff>=5  then gc_setColor((love.timer.getTime()%0.1)<0.05 and 1 or 0.5,1,  0,1)
            else                 gc_setColor((love.timer.getTime()%0.04)<0.02 and 1 or 0.2,1,  0,1) end
            diff=string.format('%.3f',diff)
            mStr(STRING.time(D.torikanTime/60).." / "..STRING.time(D.torikanGoal/60).."\n(+"..diff.."s)",300,480)
        end

        if doom_garb[getSection(D.pt)] then drawGarbageMeter(P,D.garbageCounter/doom_garb[getSection(D.pt)]) end

        ::skip_ultraBone::
        if D.ultraBone then
            gc_setColor(0,1,0)
            if D.torikanTimer>=0 and D.torikanTimer<200 then
                mStr("EXCELLENT",300,200)
                if D.torikanTimer>120 then return end
                mStr("but...",300,260)
                if D.torikanTimer>40 then return end
                mStr("let's go better",300,320)
                mStr("next time",300,370)
                if D.torikanTimer>0 then return end
                local diff=string.format('%.3f',(D.torikanTime-D.torikanGoal)/60)
                mStr(STRING.time(D.torikanTime/60).." / "..STRING.time(D.torikanGoal/60).."\n(+"..diff.."s)",300,480)
            end
            gc.draw(border,-17+150,-12)

            ultraBone.draw(P,repMode)
            if drawFrames%300==0 then collectgarbage('collect') end
            gc_pop()
        end
        drawFrames=drawFrames+1
    end,
    hook_drop=function(P)
        local D=P.modeData

        if D.rollStarted then
            D.rollLines=D.rollLines+#P.clearedRow
            return
        end


        if doom_garb[getSection(D.pt)] then D.garbageCounter=math.max(D.garbageCounter+1-#P.clearedRow,0) end
        local c=#P.clearedRow
        if c==0 and D.pt+1==D.target then return end
        local s=c<3 and c+1 or c==3 and 5 or 7
        if P.combo>7 then s=s+2
        elseif P.combo>3 then s=s+1
        end
        D.pt=math.min(D.pt+s,1800)

        if D.pt+1==D.target and not D.rollStarted then
            SFX.play('warn_1')
        elseif D.pt>=D.target and not D.rollStarted then--Level up!
            s=D.target==1799 and 18 or D.target/100
            local E=P.gameEnv
            E.lock=doom_lock[s+1]
            E.wait=doom_wait[s+1]
            E.fall=doom_fall[s+1]
            if E.das~=doom_das[s+1] then E.das=doom_das[s+1] end
            if BG.cur=='dos'then 
                BG.send('levelUp',
                    {s+1,nil,
                    doom_lock[s+1]==doom_lock[s]and nil or doom_lock[s+1],
                    doom_wait[s+1]==doom_wait[s]and nil or doom_wait[s+1],
                    doom_fall[s+1]==doom_fall[s]and nil or doom_fall[s+1],nil,nil,
                    doom_das[s+1]==doom_das[s]and nil or doom_das[s+1],nil,
                    doom_garb[s+1]==doom_garb[s]and nil or doom_garb[s+1],
                    }
                )
            end

            if s==2 then BG.set('rainbow')
            elseif s==4 then BG.set('rainbow2')
            elseif s==5 then
                if P.stat.time>135 then -- torikan: 2min 15s
                    D.pt=500
                    P.waiting=1e99
                    D.torikanTimer=300
                    D.torikanGoal=135*60
                    D.torikanTime=P.stat.time/60
                    BGM.stop()
                    return
                else
                    P.gameEnv.freshLimit=9
                    BG.set('glow')
                    BGM.play('reason')
                end
            elseif s==6 then BG.set('lightning')
            elseif s==10 then
                if P.stat.time>260 then -- torikan: 4min 20s
                    D.pt=1000
                    P.waiting=1e99
                    D.torikanTimer=300
                    D.torikanGoal=260*60
                    D.torikanTime=P.stat.time/60
                    BGM.stop()
                    return
                end
                E.bone=true
                BGM.play('down')
            elseif s==12 then
                BG.set('dos')
                P.gameEnv.shakeFX=0
                P.draw=function(P,repMode)for i=1,#P.gameEnv.mesDisp do P.gameEnv.mesDisp[i](P,repMode)end end
                D.ultraBone=1
                P.waiting=40
                BGM.play('rectification')
            elseif s==15 then 
                if P.stat.time>360 then -- torikan: 6min
                    D.pt=1500
                    P.waiting=1e99
                    D.torikanTimer=300
                    D.torikanGoal=360*60
                    D.torikanTime=P.stat.time/60
                    BGM.stop()
                    return
                end
                D.ultraBone=2
                P.waiting=30
                BGM.play('distortion')
                P:setInvisible(150)
                D.drop=1e99
            elseif s==16 then
                P:setInvisible(50)
                D.hideHold=true
            elseif s==17 then P:setInvisible(15)
            elseif s==18 then
                BGM.play('final')
                P:setInvisible(0)
                D.rollStarted=true
                P.waiting=300
                D.pt=1799
            end
            D.target=D.target==1700 and 1799 or D.target+100
            P:stageComplete(s)
            SFX.play('reach')
        end
    end,
    hook_die=function(P)
        if P.modeData.pt>=1200 and BG.cur=='dos'then BG.send('die')end
    end,
    task=function(P)
        D=P.modeData
        P:set20G(true)
        D.pt=1780
        D.target=1200
        D.torikanTimer=-1
        D.rollStarted=false
        D.rollTransTimer=300
        D.ultraBone=false
        D.rollLines=0
        D.hideHold=false
        while true do
            local prevTime=P.stat.time
            local prevFrame=P.stat.frame
            YIELD()

            if D.torikanTimer>=0 then
                for y=1,#P.field do for x=1,10 do
                    P.visTime[y][x]=D.torikanTimer-240
                end end
                D.torikanTimer=D.torikanTimer>0 and math.max(D.torikanTimer-1,0) or D.torikanTimer
                P.stat.time,P.stat.frame=prevTime,prevFrame
            end
            if D.torikanTimer==0 then P:win('finish') return end


            if D.rollTransTimer>=0 and D.rollStarted then
                D.rollTransTimer=D.rollTransTimer-1
            end
            if D.rollTransTimer<300 and D.rollTransTimer>240 then
                for y=1,#P.field do for x=1,10 do
                    P.visTime[y][x]=D.rollTransTimer-240
                end end
            end
            if D.rollTransTimer<300 and D.rollTransTimer>0 then
                D.rollStartTime=P.stat.time
            end
            if D.rollTransTimer==240 then
                TABLE.cut(P.field)
                TABLE.cut(P.visTime)
            elseif D.rollTransTimer==180 then playReadySFX(3,3)
            elseif D.rollTransTimer==120 then playReadySFX(2,2)
            elseif D.rollTransTimer==60 then playReadySFX(1,1)
            elseif D.rollTransTimer==0 then
                playReadySFX(0,1)
                D.rollStartTime=P.stat.time
            end

            if P.stat.time>D.rollStartTime+60 and D.rollTransTimer<0 then P:win('finish') end

            if doom_garb[getSection(D.pt)] and D.garbageCounter>doom_garb[getSection(D.pt)] then sendGarbage(P) end
        end
    end,
}
