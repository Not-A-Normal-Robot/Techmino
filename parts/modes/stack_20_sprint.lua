return{
    env={
        drop=60,lock=60,
        wait=0,fall=50,
        hang=15,
        garbageSpeed=30,
        seqData={1,2,3,4,5,6,7},
        eventSet='stack_20_sprint',
        bg='blockrain',bgm='there',
    },
    load=function()
        PLY.newPlayer(1)
        if SETTING.RS~="BiRS" then
            MES.new('warn',text.rightRS)
        end
    end,
	score=function(P)return{P.stat.time,P.stat.piece}end,
    scoreDisp=function(D)return STRING.time(D[1]).."   "..D[2].." Pieces"end,
    comp=function(a,b)return a[1]<b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)

        if P.stat.row<20 then return end
        local T=P.stat.time
        return
        T<=26 and 5 or
        T<=29 and 4 or
        T<=33 and 3 or
        T<=45 and 2 or
        T<=53 and 1 or
		0
		end,
}
