return{
    env={
        freshLimit=12,
        sequence="bagES",
        eventSet='master_doom',
        bg='bg2',bgm='super7th',
    },
    slowMark=true,
    score=function(P)return{P.result=='win',P.modeData.pt,P.stat.time}end,
    scoreDisp=function(D)
        if D[1]and D[2]>=1799 then return"CLEAR   "..STRING.time(D[3])end
        return D[2].."P   "..STRING.time(D[3])
    end,
    comp=function(a,b)
        return
        (a[1]and not b[1]) -- clear?
        or((a[1]==b[1]and a[2]>b[2]) -- pt
        or (a[2]==b[2]and a[3]<b[3]) -- time
        )
    end,
    getRank=function(P)
        local S=P.modeData.pt
        return
            (P.result=='win' and S>=1799)and 5 or
            S>=1500 and 4 or
            S>=1200 and 3 or
            S>=600 and 2 or
            S>=300 and 1 or
            S>=50 and 0
    end,
}
