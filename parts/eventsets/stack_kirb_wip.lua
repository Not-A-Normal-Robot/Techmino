 return{
	
	
    fieldH=20,
    fillClear=false,
	task=function(P)
			P:_showText("Get 18+",0,-120,80,'fly',.55)
			P.modeData.lineReq=18
		end,
    mesDisp=function(P)
	
        setFont(60)
        mStr(P.stat.row,63,280)
        mText(TEXTOBJ.line,63,350)
        PLY.draw.drawMarkLine(P,20,.3,1,1,TIME()%.42<.21 and .95 or .6)
    end,
	
    hook_die=function(P)
        local cc=P:clearFilledLines(P.garbageBeneath+1,#P.field-P.garbageBeneath)
        if cc>0 then
			if cc<P.modeData.lineReq then
			P:lose()
			else
			if cc>=P.modeData.lineReq then
				--P:win()
				P.modeData.lineReq=P.modeData.lineReq+1
				 
            local h=20-cc-P.garbageBeneath
            if h>0 then
                P:garbageRise(21,h,2e10-1)
                if P.garbageBeneath>=20 then
                    P:lose()
						end
					end 
				end
			end
		end
    end,
}