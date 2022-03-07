local gc=love.graphics
return
{
    drop=0,lock=15,
    wait=6,fall=6,
    fieldH=8,
    das=6,
    bone=true,
    mesDisp=function(P)
        gc.setLineWidth(2)
        gc.setColor(.98,.98,.98,.8)
        gc.rectangle('line',0,260,126,80,4)
        gc.setColor(.98,.98,.98,.4)
        gc.rectangle('fill',0+2,260+2,126-4,80-4,2)
        setFont(45)
        local t=P.stat.frame/60
        local T=("%.1f"):format(60-t)
        gc.setColor(COLOR.dH)
        mStr(T,65,270)
        t=t/120
        gc.setColor(1.7*t,2.3-2*t,.3)
        mStr(T,63,268)
    end,
    task=function(P)
        local F=P.field
        for i=1,24 do
            F[i]=LINE.new(20)
            P.visTime[i]=LINE.new(20)
            for x=3,7 do F[i][x]=0 end
        end
        P.modeData.target=50
        while true do
            YIELD()
            if P.stat.frame>3600 then
                P.win('finish')
                break
            end
        end
    end,
}
