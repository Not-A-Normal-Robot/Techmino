return {
    das=16,arr=6,
    sddas=1,sdarr=1,
    irs=false,ims=false,
    drop=1,lock=1,
    wait=10,fall=25,
    freshLimit=0,
    fieldH=19,
    nextCount=1,
    holdCount=0,
    RS='Classic',
    sequence='rnd',
    noTele=true,
    keyCancel={5,6},
    mesDisp=function(P)
        setFont(75)
        local D=P.modeData
        GC.mStr(getClassicLevelString(D.lvl),63,210)
        mText(TEXTOBJ.speedLV,63,290)
        PLY.draw.drawProgress(P.stat.row,D.target)
        if D.drought>7 then
            if D.drought<=14 then
                GC.setColor(1,1,1,D.drought/7-1)
            else
                local gb=D.drought<=21 and 2-D.drought/14 or .5
                GC.setColor(1,gb,gb)
            end
            setFont(50)
            GC.mStr(D.drought,63,130)
            mDraw(MODES.drought_l.icon,63,200,nil,.5)
        end
    end,
    task=function(P)
        P.modeData.lvl=29
        P.modeData.target=10
    end,
    hook_drop=function(P)
        local D=P.modeData
        D.drought=P.lastPiece.id==7 and 0 or D.drought+1
        if P.stat.row>=D.target then
            if D.target>=200 then P:win('finish') return end
            SFX.play('reach')
            D.lvl=D.lvl+1
            D.target=D.target+10
        end
    end,
}
