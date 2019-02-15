-- WonderlandModel
-- 须于仙境模块数据
local WonderlandModel = class("WonderlandModel", BaseModel)

function WonderlandModel:init(d)
	WonderlandModel.super.init(self, d)
	self.initdata = {}

	self.maxfloor = 0   ---最大层级
	self.selectbossType = nil
	self:registEvent()
	self.alldata = self._data
	self:sendHomeRed()
end

function WonderlandModel:registEvent()
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, 
        self.blockBattleEnd, self);
end

function WonderlandModel:updateData(data)
	WonderlandModel.super.updateData(self,data)
end

function WonderlandModel:setSelectBossType( bossType )
	self.selectbossType = bossType
end

function WonderlandModel:getSelectBossType()
	return self.selectbossType 
end


function WonderlandModel:getMaxfloor(_type)
	dump(self.alldata,"所有数据")


	if  self.alldata[tostring(_type)] ~= nil then
		self.maxfloor = self.alldata[tostring(_type)]
	else
		self.maxfloor = 0
	end
	-- self.maxfloor = 19   --测试用
	return  self.maxfloor
end


---左右移动的条件判断_r_f右 -1    左 +1
function WonderlandModel:judgeMoveConditions(_type,floor,_r_f)

	if floor == 0 then
		return {false }
	end
	if floor > 20 then
		return {false,FuncWonderland.ErrorStrID.ERROR_5}
	end

	if self.maxfloor == 0 then
		return {false,FuncWonderland.ErrorStrID.ERROR_2}
	end
	if _r_f > 0 then  --右
		if self.maxfloor >= FuncWonderland.MaxFloor then
			if floor  ==  self.maxfloor - 3 then
				return {false}
			end
			return {true}
		end
	   	if floor  ==  self.maxfloor then
	   		return {true}
	   	else
	   		return {false}
	   	end
	elseif _r_f < 0 then   --左
		if floor  <=  self.maxfloor + 1 then
	   		return {true}
	   	else
	   		return {false ,FuncWonderland.ErrorStrID.ERROR_2}
	   	end
	end
	return {false}
end


--获得火魔兽的挑战次数
function WonderlandModel:getWonderLandFireNum()
	local count = CountModel:getWonderLandFireNum()
	return count
end

--获得水魔兽的挑战次数
function WonderlandModel:getWonderLandWriterNum()
	local count = CountModel:getWonderLandWriterNum()
	return count
end
--获得水魔兽的挑战次数
function WonderlandModel:getWonderLandWindNum()
	local count = CountModel:getWonderLandWindNum()
	return count
end


function WonderlandModel:getBCountyType(_type)
	local count = 0
	if _type == 1 then
		count = self:getWonderLandFireNum()
	elseif _type == 2 then
		count = self:getWonderLandWriterNum()
	elseif _type == 3 then
		count = self:getWonderLandWindNum()
	elseif _type == 4 then
		count = CountModel:getWonderLandRayWindNum()
	elseif _type == 5 then
		count = CountModel:getWonderLandWaterNum()
	elseif _type == 6 then
		count = CountModel:getWonderLandLiveNum()
	elseif _type == 7 then
		count = CountModel:getWonderLandSoilNum()
	elseif _type == 8 then
		count = CountModel:getWonderLandEightNum()
	elseif _type == 9 then
		count = CountModel:getWonderLandWomanNum()
	end
	return count
end

--判断是不是扫荡
function WonderlandModel:judgeSweepOrChallengle(_type,floor)
	echo("======第几个魔兽  第几层============",_type,floor)
	local userfloor = self.alldata[tostring(_type)]
	if userfloor == nil then
		return false
	end
	if floor <= userfloor  then
		return true
	end
	return false
end


--扫荡按钮
function WonderlandModel:sweepWonderLand(params)
	
	 local function _callback(_param)
        dump(_param.result,"扫荡结果")
        if _param.result ~= nil then
       		local sweepReward = _param.result.data.sweepReward
       		WindowControler:showWindow("RewardSmallBgView", sweepReward);
       		EventControler:dispatchEvent(WonderlandEvent.WONDERLAND_SWEEP_SUCCESS)
        end
    end

    local newparams = {
		floor = params.floor,
		bossType = params.bossType
	}

	WonderlandServer:sweepWonderLand(params, _callback)
end


function WonderlandModel:challengeWonderLand(params)

	local function _callback(_param)
        -- dump(_param.result,"挑战开始结果")
        if _param.result ~= nil then
        	EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
        	local serviceData = _param.result.data.battleInfo
        	-- dump(serviceData,"serviceData=====")
        	serviceData.battleLabel = GameVars.battleLabels.wonderLandPve
			local battleInfoData = BattleControler:turnServerDataToBattleInfo(serviceData)
			BattleControler:startBattleInfo(battleInfoData)			
        end
    end 

	self:setSelectBossType(params.bossType)
	-- dump(params.formation, "\n\nparams.formation===")
	WonderlandServer:challengeWonderLand(params, _callback)
end


--战斗结束
function WonderlandModel:blockBattleEnd(data)
	local battleParams = {}

	battleParams = data.params
	if battleParams.battleLabel == GameVars.battleLabels.wonderLandPve  then 
		self._result = data.params.rt;
		self._star = data.params.star
		self:endBattle(c_func(self.endBattleCallback, self), 
		        battleParams);
	end
end
--战斗结束
function WonderlandModel:endBattle(callBack, battleParams)
	echo("----WonderlandModelServer:endBattle-----");
	-- dump(battleParams, "__battleParams_");
	local params = {
		battleResultClient = battleParams
	}
	WonderlandServer:finishWonderLand(params, callBack)
end

function WonderlandModel:endBattleCallback(event)
	local reward = {};
	local rewardData = {};
	if event.result ~= nil and event.result.data ~= nil then 
		-- dump(event.result," ======战斗结束 获得奖励======= ")
        reward = event.result.data.firstReward;
        -- reward = FuncCommon.repetitionRewardCom(reward)
	    rewardData = {
	    	reward = reward,
	        result = self._result,
	        star = self._star
	    }
	else
		rewardData = {
	    	reward = {},
	        result = Fight.result_lose,
	        star = 0,
	    }
	end
	BattleControler:showReward(rewardData)
end




--获取排行榜
function WonderlandModel:getPaiHangBang(params,callBack)
	local params = {
		type = params.type,
		rank = params.rank or 1,
		rankEnd = params.rankEnd or 1,
	}
	WonderlandServer:getPowerLuRenData(params,callBack)
end


--数据排序
function WonderlandModel:getPaiHangBangDataSorting(data)
	local newdata = {}
	if table.length(data) ~= 0 then
		for k,v in pairs(data) do
			v.rid = k
			newdata[v.rank] = v
		end
	end

	return newdata
end

function WonderlandModel:shoehomeRed()
	if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.WONDERLAND) then
		return false
	end
	
	local data = FuncWonderland.getdifferTypeData()
	local count = 0
	local num = FuncWonderland.getChallengCount()
	-- local fonum = #data
	local sumnum = 0
	for k,v in pairs(data) do
		if v.open then
			count  =  count + self:getBCountyType( tonumber(v.id))
			sumnum = sumnum + num
		end
	end
		
	if sumnum - count > 0 then
		return true
	end 
	return false
end

function WonderlandModel:sendHomeRed()
	
	local isShow = self:shoehomeRed()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, 
		{redPointType = HomeModel.REDPOINT.DOWNBTN.ELITE, isShow = isShow})

end

function WonderlandModel:getSumCountNum()
	local data = FuncWonderland.getdifferTypeData()
	local count = 0
	local num = FuncWonderland.getChallengCount()
	local sumnum = 0
	for k,v in pairs(data) do
		if v.open then
			count  =  count + self:getBCountyType( tonumber(v.id))
			sumnum = sumnum + num
		end
	end

	return sumnum - count 
end


--获取须臾仙境里面所有最高层
function WonderlandModel:getAllMaxFloor()
	local alldata = self._data
	local max = nil
	for k,v in pairs(alldata) do
		if max == nil then
			max = v
		else
			if max < v then
				max = v
			end
			
		end
	end
	return max or 0
end

function WonderlandModel:getAllMinFloor()
	local alldata = self._data
	local min = nil
	--这个地方如果玩法类型个数发生了变化 需要改变  TODO
	local type_count = #FuncWonderland.getdifferTypeData()
	if table.length(alldata) < type_count then
		return 0
	end
	
	for k,v in pairs(alldata) do
		if min == nil then
			min = v
		else
			if min > v then
				min = v
			end			
		end
	end
	return min or 0
end


return WonderlandModel
