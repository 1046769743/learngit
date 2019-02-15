--
--Author:      zhuguangyuan
--DateTime:    2017-09-18 17:14:59
--Description: 任务条件model
-- 对任务相关数据进行统计
-- 判断任务是否完成

local CarnivalTaskConditionModel = class("CarnivalTaskConditionModel", BaseModel)

-- 服务器记录非追溯类任务完成进度数据
-- 在登录的时候发送过来
-- 'scheduleId'        // 调度id
-- 'conditionId'       // 条件id
-- 'count'             // 完成次数
-- 'param'             // 领取参数
-- 'expireTime'        // 过期时间
function CarnivalTaskConditionModel:init(d)
	-- self._data = d
	CarnivalTaskConditionModel.super.init(self, d)
	-- dump(self._data, "\n\nself._data===")
	ActConditionModel:init(d)
end

function CarnivalTaskConditionModel:updateData(d)
	CarnivalTaskConditionModel.super.updateData(self, d)
	-- dump(self._data,"\n\n服务器更新 CarnivalTaskConditionModel ---- self._data--- ")
	ActConditionModel:updateData(d)
end

-- 取得由服务器统计的任务完成数据
function CarnivalTaskConditionModel:getNotTraceConditionByKey(key)
	local data = self._data[key]
	if not data then
		-- WindowControler:showTips( { text = "服务器没有做相关统计---key--"..key })
		return 0
	end
	local num = data.count or 0
	-- echo(" -- key,data.count,num ---= ", key, data.count, num)
	if data.expireTime then
		if data.expireTime < TimeControler:getServerTime() then
			num = 0
		end
	end
	-- echo("\n\n服务器统计 -- key,data.count,num ---= ",key,data.count,num)
	return num
end

-- 判断任务是否完成
-- 完成则可以领取奖励
-- 用于判断任务状态
function CarnivalTaskConditionModel:isTaskConditionOk(themeId, taskId)
	local conditionId = FuncCarnival.getTaskConditionIdById(taskId)
	local actType = FuncCarnival.getTaskTypeById(taskId)
	-- if not FuncActivity.checkTaskCanDoByLevel(taskId) then
	-- 	return false
	-- end

	local key = string.format("%s_%s", themeId, conditionId)
	if actType == FuncCarnival.ACT_TYPE.EXCHANGE then  --兑换类
		local conditionParam = FuncCarnival.getTaskConditionParamById(taskId)
		for _, res in pairs(conditionParam) do
			local needNum,hasNum,isEnough,resType,resId = UserModel:getResInfo(res)
			if not isEnough then
				return false
			end
		end
		return true
	elseif actType == FuncCarnival.ACT_TYPE.TASK then  --任务类(追溯、非追溯)
		local currentCondition = self:getNotTraceConditionByKey(key)
		local configConditionNum = FuncCarnival.getTaskConditionNumById(taskId)
		local dataIsTrace = FuncCarnival.getTaskTraceById(taskId)
		local conditionParam = FuncCarnival.getTaskConditionParamById(taskId)

		-- 追溯类的，单独处理
		-- 非追溯的读取服务器的进度
		if dataIsTrace == 1 then
			local handleFuncKey = FuncCarnival.TRACE_TASK_FUNCS[tonumber(conditionId)]
			local funcKey = nil
			if handleFuncKey then
				funcKey = string.format("%sConditionOk", handleFuncKey)
			end
			if handleFuncKey and self[funcKey] then
				local func = self[funcKey]
				local isOk = func(self, configConditionNum, conditionParam)
				return isOk
			end
		else
			if tonumber(configConditionNum) <= currentCondition then
				return true
			else
				return false
			end
		end
	end
	return false
end

-- 任务的完成进度
-- 用在界面展示
function CarnivalTaskConditionModel:getTaskConditionProgress(themeId, taskId)
	local conditionId = FuncCarnival.getTaskConditionIdById(taskId)
	local key = string.format("%s_%s", themeId, conditionId)
	local dataIsTrace = FuncCarnival.getTaskTraceById(taskId)
	local configConditionNum = FuncCarnival.getTaskConditionNumById(taskId)
	local conditionParam = FuncCarnival.getTaskConditionParamById(taskId)

	local count = 0
	-- 追溯类的，根据key找对应函数进行处理
	-- 非追溯的读取服务器的进度
	if dataIsTrace == 1 then 
		local handleFuncKey = FuncCarnival.TRACE_TASK_FUNCS[tonumber(conditionId)]
		local funcKey = nil

		if handleFuncKey then
			funcKey = string.format("%sCurrentConditionNum", handleFuncKey)
		end

		if handleFuncKey and self[funcKey] then
			local func = self[funcKey]
			count = func(self, conditionParam)
		end
	else 
		count = self:getNotTraceConditionByKey(key)
	end
	-- echo("\n显示任务状态Model中----dataIsTrace,themeId,taskId,conditionId,count,configConditionNum ------",dataIsTrace,themeId, taskId , conditionId ,count , configConditionNum)
	return count, configConditionNum
end


--=====================================================
-- 等级关卡
--=====================================================	
--玩家等级 
function CarnivalTaskConditionModel:userLevelConditionOk(conditionNum)
	local current = self:userLevelCurrentConditionNum()
	if current >= tonumber(conditionNum) then
		return true
	end
	return false
end

function CarnivalTaskConditionModel:userLevelCurrentConditionNum()
	return UserModel:level()
end

-- 主线副本
function CarnivalTaskConditionModel:mainLineConditionOk(raidId)
	local current = self:mainLineCurrentConditionNum()
	if tonumber(current) >= tonumber(raidId) then
		return true
	end
	return false
end
function CarnivalTaskConditionModel:mainLineCurrentConditionNum()
	return UserExtModel:getMainStageId()
end

-- 精英副本
function CarnivalTaskConditionModel:eliteConditionOk(raidId)
	local current = self:eliteCurrentConditionNum()
	if tonumber(current) >= tonumber(raidId) then
		return true
	end
	return false
end
function CarnivalTaskConditionModel:eliteCurrentConditionNum()
	return UserExtModel:getEliteStageId()
end

--=====================================================
-- 登仙台
--=====================================================	
function CarnivalTaskConditionModel:pvpRankConditionOk(conditionNum)
	local current = self:pvpRankCurrentConditionNum()
	if tonumber(current) <= tonumber(conditionNum) then
		return true
	end
	return false
end
function CarnivalTaskConditionModel:pvpRankCurrentConditionNum()
	local isOpen = FuncCommon.isSystemOpen("pvp")
	if not isOpen then
		return FuncPvp.DEFAULT_RANK
	end
	-- echo(" ===== 等仙台排名 === ",PVPModel:getHistoryTopRank())
	return PVPModel:getHistoryTopRank()
end

--=====================================================
-- 锁妖塔
--=====================================================	
-- 锁妖塔
function CarnivalTaskConditionModel:towerFloorConditionOk(conditionNum)
	local current = self:userLevelCurrentConditionNum()
	if tonumber(current) >= tonumber(conditionNum) then
		return true
	end
	return false
end

function CarnivalTaskConditionModel:towerFloorCurrentConditionNum()
	return UserExtModel:getEliteStageId()
end












--=====================================================
-- 法宝
--=====================================================	
--拥有XX个X资质法宝
function CarnivalTaskConditionModel:haveXXQualityTreasureNumXXConditionOk(conditionNum, conditionParam)
	local haveNum = self:haveXXQualityTreasureNumXXCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:haveXXQualityTreasureNumXXCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local _aptitude = tonumber(paramArray[1]);
	local haveNum =  TreasureNewModel:getEnoughAptitudeNum(_aptitude) -- TreasuresModel:function_name(starNum - 1); 
	return haveNum or 0
end

--拥有XX个X星法宝
function CarnivalTaskConditionModel:haveXXStarTreasureNumXXConditionOk(conditionNum, conditionParam)
	local haveNum = self:haveXXStarTreasureNumXXCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:haveXXStarTreasureNumXXCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local _star = tonumber(paramArray[1]);
	local haveNum = TreasureNewModel:getEnoughStarNum(_star) -- TreasuresModel:function_name(starNum - 1); 
	return haveNum or 0
end









--=====================================================
-- 伙伴
--=====================================================	
--拥有X个X星的伙伴
function CarnivalTaskConditionModel:haveStarOverPartnerConditionOk(conditionNum, conditionParam)
	--获得有几个大于star参数星级的伙伴
	local haveNum = self:haveStarOverPartnerCurrentConditionNum(conditionParam)

	return haveNum >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:haveStarOverPartnerCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local starNum = tonumber(paramArray[1]);

	--获得有几个大于star参数星级的伙伴
	local haveNum = PartnerModel:partnerNumGreaterThenParamStar(starNum - 1); 
	return haveNum
end


--x个伙伴达到XX品质
function CarnivalTaskConditionModel:haveQualityOverPartnerConditionOk(conditionNum, conditionParam)
	--获得有几个大于quality参数星级的伙伴
	local haveNum = self:haveQualityOverPartnerCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:haveQualityOverPartnerCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local qualityNum = tonumber(paramArray[1]);
	
	--获得有几个大于quality参数星级的伙伴
	local haveNum = PartnerModel:partnerNumGreaterThenParamQuality(qualityNum - 1); 
	return haveNum
end


--拥有X个XX等级的绝技 
function CarnivalTaskConditionModel:haveUniqueSkillOverPartnerConditionOk(conditionNum, conditionParam)
	local num = self:haveUniqueSkillOverPartnerCurrentConditionNum(conditionParam)
	return num >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:haveUniqueSkillOverPartnerCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local lvl = tonumber(paramArray[1]);

	local num = PartnerModel:getUniqueSkillLevelOverThenParamNum(lvl - 1);
	return num 
end


--拥有XX伙伴
function CarnivalTaskConditionModel:havePartnerConditionOk(conditionNum, conditionParam)
	local haveNum = self:havePartnerCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:havePartnerCurrentConditionNum(conditionParam)
	local paramArray = conditionParam
	local haveNum = 0
	local count = 0
	for i,v in ipairs(paramArray) do
		if PartnerModel:isHavedPatnner(tostring(v)) then
			count = count + 1
		end
	end

	if count == #paramArray then
		haveNum = 1
	end
	return haveNum
end


--XX伙伴等级达到XX级
function CarnivalTaskConditionModel:partnerLevelOverConditionOk(conditionNum, conditionParam)
	local level = self:partnerLevelOverCurrentConditionNum(conditionParam)
	return level >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:partnerLevelOverCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local partnerId = tonumber(paramArray[1]);
	if PartnerModel:isHavedPatnner(partnerId) == false then
		return false;
	end 

	local partner = PartnerModel:getPartnerDataById(partnerId);
	if not partner then
		return false
	end
	return partner.level
end


--XX伙伴达到X星
function CarnivalTaskConditionModel:partnerStarOverConditionOk(conditionNum, conditionParam)
	local star = self:partnerStarOverCurrentConditionNum(conditionParam)
	return star >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:partnerStarOverCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local partnerId = tonumber(paramArray[1]);
	if PartnerModel:isHavedPatnner(partnerId) == false then
		return false;
	end 

	local partner = PartnerModel:getPartnerDataById(partnerId);
	if not partner then
		return false
	end
	return partner.star
end


--XX伙伴达到XX品质
function CarnivalTaskConditionModel:partnerQualityOverConditionOk(conditionNum, conditionParam)
	local quality = self:partnerQualityOverCurrentConditionNum(conditionParam)
	return quality >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:partnerQualityOverCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local partnerId = tonumber(paramArray[1]);
	if PartnerModel:isHavedPatnner(partnerId) == false then
		return false;
	end 

	local partner = PartnerModel:getPartnerDataById(partnerId);
	if not partner then
		return false
	end
	return partner.quality
end


--XX伙伴绝技达到XX级 
function CarnivalTaskConditionModel:partnerUniqueSkillOverConditionOk(conditionNum, conditionParam)
	local skillLevel = self:partnerUniqueSkillOverCurrentConditionNum(conditionParam)
	return skillLevel >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:partnerUniqueSkillOverCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local partnerId = tonumber(paramArray[1]);

	if PartnerModel:isHavedPatnner(partnerId) == false then
		return false;
	end 

	local partner = PartnerModel:getPartnerDataById(partnerId);
	if not partner then
		return false
	end
	local totalUniqueSkillLvl = PartnerModel:getUniqueSkillTotalLevelByPartnerId(partnerId);
	return totalUniqueSkillLvl
end


--拥有XX个伙伴
function CarnivalTaskConditionModel:partnerHaveConditionOk(conditionNum, conditionParam)
	local num = self:partnerHaveCurrentConditionNum(conditionParam)
	return num >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:partnerHaveCurrentConditionNum(conditionParam)
	--zgytodo 伙伴系统里要做是否有伙伴的检查
	-- 没有则返回0 
	return PartnerModel:getPartnerNum()
end


--拥有XX个XX等级的伙伴
function CarnivalTaskConditionModel:haveLevelOverPartnerConditionOk(conditionNum, conditionParam)
	--获得有几个大于quality参数星级的伙伴
	local haveNum = self:haveLevelOverPartnerCurrentConditionNum(conditionParam)

	return haveNum >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:haveLevelOverPartnerCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local levelNum = tonumber(paramArray[1]);
	
	--获得有几个大于quality参数星级的伙伴
	local haveNum = PartnerModel:partnerNumGreaterThenParamLvl(levelNum - 1); 
	return haveNum
end


--X件装备达到XX品质
function CarnivalTaskConditionModel:haveQualityOverEquipsConditionOk(conditionNum, conditionParam)
	local haveNum = self:haveQualityOverEquipsCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
function CarnivalTaskConditionModel:haveQualityOverEquipsCurrentConditionNum(conditionParam)
	local paramArray = string.split(conditionParam[1],",");
	local qualityNum = tonumber(paramArray[1]);

	local haveNum = PartnerModel:getEquipmentNumByMorethanquality(qualityNum - 1);
	return haveNum
end

-- --拥有xx奇侠组合（支持多个） 废弃 使用2108     havePartnerCurrentConditionNum
-- --判断是否完成目标条件
-- function CarnivalTaskConditionModel:havePartnerGroupConditionOk(conditionNum, conditionParam)
-- 	local haveNum = self:havePartnerGroupCurrentConditionNum(conditionParam)
-- 	return haveNum >= conditionNum and true or false;
-- end
-- --判断是否拥有指定奇侠组合
-- function CarnivalTaskConditionModel:havePartnerGroupCurrentConditionNum(conditionParam)
-- 	local paramArray = conditionParam
-- 	local haveNum = 0
-- 	local count = 0
-- 	for i,v in ipairs(paramArray) do
-- 		if PartnerModel:isHavedPatnner(tostring(v)) then
-- 			count = count + 1
-- 		end
-- 	end

-- 	if count == #paramArray then
-- 		haveNum = 1
-- 	end
-- 	return haveNum
-- end

--拥有X套X颜色的神器
--判断是否完成目标条件
function CarnivalTaskConditionModel:haveArtifactGroupConditionOk(conditionNum, conditionParam)
	local haveNum = self:haveArtifactGroupCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
--判断指定颜色的神器拥有多少件
function CarnivalTaskConditionModel:haveArtifactGroupCurrentConditionNum(conditionParam)
	local tragetColor = conditionParam[1]
	local carnivalType = FuncArtifact.carnivalType.COLOR_TYPE
	local haveNum = ArtifactModel:getArtifactCountByQualityOrAdvance(carnivalType, tragetColor)
	return haveNum
end

--X套神器进阶到+X
--判断是否完成目标条件
function CarnivalTaskConditionModel:haveArtifactAdvanceConditionOk(conditionNum, conditionParam)
	local haveNum = self:haveArtifactAdvanceCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
--获取神器进阶到+X的有多少件
function CarnivalTaskConditionModel:haveArtifactAdvanceCurrentConditionNum(conditionParam)
	local tragetAdvancedNum = conditionParam[1]
	local carnivalType = FuncArtifact.carnivalType.ADVANCED_TYPE
	local haveNum = ArtifactModel:getArtifactCountByQualityOrAdvance(carnivalType, tragetAdvancedNum)
	return haveNum
end

--是否达到巅峰竞技场对应段位
--判断是否完成目标条件
function CarnivalTaskConditionModel:achieveCrossPeakSegmentConditionOk(conditionNum, conditionParam)
	local haveNum = self:achieveCrossPeakSegmentCurrentConditionNum(conditionParam)
	return haveNum >= conditionNum and true or false;
end
--是否达到目标段位
function CarnivalTaskConditionModel:achieveCrossPeakSegmentCurrentConditionNum(conditionParam)
	local tragetCrossPeakSegment = conditionParam[1]
	local haveNum = 0
	local maxSegment = CrossPeakModel:getHistoryMaxSegment()
	if tonumber(maxSegment) >= tonumber(tragetCrossPeakSegment) then
		haveNum = 1
	end
	return haveNum
end

return CarnivalTaskConditionModel















