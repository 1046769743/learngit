--
-- Author: xd
-- Date: 2018-05-18 16:43:53
--

local checkResultMap = {
	mustCheck = 1, 		--必定校验
	neededCheck = 0,		--按需校验
	noCheck = -1 		--不需要校验
}

local checkRuleMap = {
	ability = 1, 		--战力校验
	star = 2,			--星级校验
	damage = 3,			--伤害校验
}

local checkMessageMap = {
	labelCheck = "no check by label ,label:%s",
	resultCheck = "no check by battle lose ,label: %s",
	abilityCheck = "no check by ability over ,label: %s, current: %d,needed: %d",
	starCheck = "no check by star less ,label:%s, current: %d,needed: %d",

	mustChecklabel = "must check by label ,  label:%s",
	mustCheckResult = "must check by battle lose ,label: %s",
	mustCheckAbility = "must check by ability less ,label: %s, current: %d,needed: %d",
	mustCheckStar = " must check by star more ,label:%s, current: %d,needed: %d",
}

BattleCheckControler = {}
BattleCheckControler.checkMessage = "normal check"
function BattleCheckControler:checkBattleResut( battleInfo )
	self.checkMessage = "normal check"
	if IS_MUST_BATTLECHECK then
		return true
	end
	--先判定结果
	local rt = self:checkMustBattle(battleInfo)

	--如果是必定校验的
	if rt == checkResultMap.mustCheck  then
		return true
	--不需要校验的
	elseif rt == checkResultMap.noCheck  then
		return false,battleInfo.battleResultClient
	end

	--在判断失败不需要校验
	rt = self:checkLose(battleInfo)
	--如果是必定校验的
	if rt == checkResultMap.mustCheck  then
		return true
	--不需要校验的
	elseif rt == checkResultMap.noCheck  then
		return false,battleInfo.battleResultClient
	end

	--在根据规则判定是否校验
	rt = self:checkRule(battleInfo,objLevel)
	--如果是必定校验的
	if rt == checkResultMap.mustCheck  then
		return true
	--不需要校验的
	elseif rt == checkResultMap.noCheck  then
		return false
	end

end



--所有的校验 1 表示可以需要校验, 0 表示 可能需要校验, -1表示一定不需要校验
--判断必须要校验的关卡
function BattleCheckControler:checkMustBattle( battleInfo )
	local battleLabel = battleInfo.battleLabel
	if not  battleInfo.battleResultClient then
		return checkResultMap.mustCheck
	end
	--必定校验的关卡
	if battleLabel == GameVars.battleLabels.pvp 
		or battleLabel == GameVars.battleLabels.crossPeakPvp  
		or battleLabel == GameVars.battleLabels.crossPeakPvp2  
		or battleLabel == GameVars.battleLabels.guildBossPve  
		or battleLabel == GameVars.battleLabels.shareBossPve  

		then
		self.checkMessage = string.format(checkMessageMap.mustChecklabel, battleLabel) 
		return checkResultMap.mustCheck
	elseif battleLabel == GameVars.battleLabels.missionBattlePve 
		or battleLabel == GameVars.battleLabels.missionMonkeyPve
		or battleLabel == GameVars.battleLabels.missionIcePve
		or battleLabel == GameVars.battleLabels.missionBombPve
		or battleLabel == GameVars.battleLabels.crossPeakPve 
		then
		self.checkMessage = string.format(checkMessageMap.labelCheck, battleLabel) 
		return  checkResultMap.noCheck
	else
		return checkResultMap.neededCheck
	end

end


--判断失败需要校验的关卡
function BattleCheckControler:checkLose( battleInfo )
	-- 目前可以判定所有的失败都不需要校验
	local battleLabel = battleInfo.battleLabel
	local battleRt = battleInfo.battleResultClient.rt
	if battleRt == Fight.result_lose then
		self.checkMessage = string.format(checkMessageMap.resultCheck, battleLabel) 
		return checkResultMap.noCheck
	end
	return checkResultMap.neededCheck
	
end



--根据规则校验
function BattleCheckControler:checkRule( battleInfo )
	
	local levelId = battleInfo.levelId
	local levelCfg = require("level.Level")
	local data =  levelCfg[tostring(levelId)]
	if not data then
		data = levelCfg["101"]
	end
	--拿对应第一行的数据
	local levelData = data["1"]
	local btcheck = levelData.btcheck
	local star = battleInfo.battleResultClient.star 
	local totalAbility = FuncChar.getCharAllPower(battleInfo.battleUsers[1],battleInfo.battleUsers[1].formation or battleInfo.formation )

	-- btcheck = {
	-- 	{
	-- 		t= 1,
	-- 		v= 1,
	-- 	}
	-- }

	--没有校验规则 就是三星不校验
	if not btcheck then
		-- print(star,"_______star")
		local needStar = 7
		if star < needStar then
			self.checkMessage = string.format(checkMessageMap.starCheck, battleInfo.battleLabel,star,needStar) 
			return checkResultMap.noCheck
		else
			self.checkMessage = string.format(checkMessageMap.mustCheckStar, battleInfo.battleLabel,star,needStar) 
			return checkResultMap.mustCheck
		end
		-- btcheck = {
		-- 	{
		-- 		t = checkRuleMap.ability,
		-- 		v = -1,
		-- 	}
		-- }

	end
	--遍历校验规则
	for i,v in ipairs(btcheck) do
		--如果是战力校验
		if v.t == checkRuleMap.ability then
			if v.v == -1 then
				self.checkMessage = string.format(checkMessageMap.mustCheckAbility, battleInfo.battleLabel,totalAbility,v.v) 
				return checkResultMap.mustCheck
			else
				--如果战力小于目标战力 那么也必定校验
				if totalAbility < v.v then
					self.checkMessage = string.format(checkMessageMap.mustCheckAbility, battleInfo.battleLabel,totalAbility,v.v)
					return checkResultMap.mustCheck
				end
			end
			self.checkMessage = string.format(checkMessageMap.abilityCheck, battleInfo.battleLabel,totalAbility,v.v) 
		--星级校验 大于等于配置的星级就校验
		elseif v.t == checkRuleMap.star then
			if star >= v.v then
				self.checkMessage = string.format(checkMessageMap.mustCheckStar, battleInfo.battleLabel,star,v.v) 
				return checkResultMap.mustCheck
			end
			self.checkMessage = string.format(checkMessageMap.starCheck, battleInfo.battleLabel,star,v.v) 
		--如果是 伤害校验
		elseif v.t == checkRuleMap.damage then
			if battleInfo.totalDamage >= v.v then
				return checkResultMap.mustCheck
			end
		end
	end
	--全部通过就必定不校验
	return checkResultMap.noCheck

end

--默认只拿第一个组玩家的战力
function BattleCheckControler:getAbility( battleInfo )
	local userInfo = battleInfo.battleUsers[1]
	--如果是 机器人 那么直接返回 很大一个数,表名应该是不需要校验的
	if userInfo.userBattleType == Fight.battle_type_robot then
		return  9999999
	end


end

