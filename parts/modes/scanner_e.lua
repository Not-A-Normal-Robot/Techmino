-- Mode originally by Discord user hanamielle
-- Keeping this because I like archiving stuff
return{
    env={
        drop=60,lock=60,
        wait=0,fall=20,
        eventSet='scanner_e',
        bg='blockfall',bgm='exploration',
    },
    score=function(P)return{P.stat.time}end,
    scoreDisp=function(D)return tostring(D[1])end,
    comp=function(a,b)return a[1]>b[1]end,
    getRank=function(P)
		if P.stat.row<40 then return end
        local T=P.stat.time
        return
        T<=40 and 5 or
        T<=45 and 4 or
        T<=50 and 3 or
        T<=60 and 2 or
        T<=70 and 1
    end,
}
