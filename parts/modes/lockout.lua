return{
    env={
        eventSet='lockout',
        bg='rgb',bgm='moonbeam',
    },
    score=function(P)return{P.stat.pc,P.stat.time}end,
    scoreDisp=function(D)return D[1].." PCs   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local L=P.stat.time
        return
        L<=50 and 5 or
        L<=60 and 4 or
        L<=75 and 3 or
        L<=90 and 2 or
        L<=100 and 1 or
        L<=120 and 0
    end,
}
