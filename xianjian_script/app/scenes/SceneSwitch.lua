


SceneSwitch={}

local targetScale = 14

--场景离开
function SceneSwitch:doSceneOut(ctn, callBack, callParams )
	local pic = display.newSprite( FuncRes.iconOther("sceneSwitchImg")):addto(ctn)
	
	pic:pos(GameVars.width/2,GameVars.height/2)
	local act_1 = cc.ScaleTo:create(12/GameVars.GAMEFRAMERATE, 14)

	local func = function (  )
		pic:clear()
		if callBack then
			if callParams then
				callBack(unpack(callParms))
			else
				callBack()
			end
		end
	end

	local act_2 = cc.DelayTime:create(5/GameVars.GAMEFRAMERATE)

	local act_3 = cc.CallFunc:create(func)

	local act_s = cc.Sequence:create(act_1,act_2,act_3)
	pic:runAction(act_s)
end


function SceneSwitch:doSceneIn( ctn,callBack,callParams )
	
	local pic = display.newSprite( FuncRes.iconOther("sceneSwitchImg")):addto(ctn)
	
	pic:pos(GameVars.width/2,GameVars.height/2)
	pic:setScale(14)
	local act_1 = cc.ScaleTo:create(12/GameVars.GAMEFRAMERATE, 0.1)

	local func = function(  )
		pic:clear()
		if callBack then
			if callParams then
				callBack(unpack(callParms))
			else
				callParams()
			end
		end
	end

	local act_2 = cc.DelayTime:create(5/GameVars.GAMEFRAMERATE)

	local act_3 = cc.CallFunc:create(func)

	local act_s = cc.Sequence:create(act_1,act_2,act_3)
	self:runAction(act_s)
end






