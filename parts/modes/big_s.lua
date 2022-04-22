-- Shirase Ending
return{
    env={
        noTele=true,
        mindas=7,minarr=1,minsdarr=1,
        freshLimit=10,
        sequence="bagES",
        hook_drop=require'parts.eventsets.bigWallGen'.hook_drop,
        eventSet='big_s',
        bg='lightning',bgm='secret7th remix',
    },
    score=function(P)return{P.stat.row,P.stat.time}end,
    scoreDisp=function(D)return D[1].." Lines   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=130 and 5 or
        L>=110 and 4 or
        L>=90 and 3 or
        L>=70 and 2 or
        L>=50 and 1 or
        L>=15 and 0
    end,
}
