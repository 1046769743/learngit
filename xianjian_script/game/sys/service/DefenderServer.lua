
local DefenderServer = class("DefenderServer")

-- function DefenderServer:godActivate(godId,callBack)
-- 	-- Server:sendRequest({ godId = godId }, MethodCode.god_activite_4101, callBack );
-- end
function DefenderServer:init()
	--战斗结束
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, self.onPVEBattleComplete, self)


end
function DefenderServer:onPVEBattleComplete(event)
	


	
end
--- 获取紫萱功能的数据详情
function DefenderServer:requestDefenderInf()
	--TODO


end
function DefenderServer:requestDefenderChallenger(callBack)
	-- Server:sendRequest({}, MethodCode.defender_requestChallenger_1501 , c_func(self.challengerDoing, self,callBack))
end
---返回挑战的进入
function DefenderServer:challengerDoing( callBack,result )
	
	if callBack then
		return callBack()
	end
end
--领取奖励 (参数typeId（1领取，2再次领取），参数callBack（回调函数）)
function DefenderServer:requestGetAward(typeId,callBack)
	if typeId == 1 then
		-- Server:sendRequest({}, MethodCode.defender_requestChallenger_1501 , c_func(self.blackGetAward, self,callBack))
	elseif typeId == 2 then
		-- Server:sendRequest({}, MethodCode.defender_requestChallenger_1501 , c_func(self.blackGetAward, self,callBack))
	end

end
--奖励返回
function DefenderServer:blackGetAward( callBack,result )
	
	if callBack then
		return callBack()
	end
end

return DefenderServer