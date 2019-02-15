--[[
	guan
	2016.4.26
	2017.2.21
]]

FuncGuide = FuncGuide or {}

local funcGuide = nil
--补充漏掉的局部变量
local battleGuide = nil
local unlockGuide = nil
local battleProcess = nil
local battleWeakGuide = nil
local partnerAwaken = nil
local videoGuide = nil

FuncGuide.GuideCondition = {
	LOGIN = "1",
	SYSTEM_OPEN = "2",
	PRO_LOGUE = "3",
};

function FuncGuide.init(  )
	funcGuide = Tool:configRequire("guide.NoviceGuide");
	battleGuide = Tool:configRequire("guide.BattleGuide");
	unlockGuide = Tool:configRequire("guide.UnlockGuide");
	battleProcess = Tool:configRequire("guide.BattleGuideProcess");
	battleWeakGuide = Tool:configRequire("guide.BattleWeakGuide")
	partnerAwaken = Tool:configRequire("guide.Awaken")
	videoGuide = Tool:configRequire("guide.VideoGuide")
end

function FuncGuide.getValueByKey(id1, id2, key, isShowErrorLog)
	local t1 = funcGuide[tostring(id1)];
	isShowErrorLog = isShowErrorLog or true;
	if t1 == nil then 
		if isShowErrorLog == true then 
			echo("FuncGuide.getValueByKey id1 not found ",id1);
		end 
		return nil;
	end 

	local t2 = t1[tostring(id2)];
	if t2 == nil then 
		if isShowErrorLog == true then 
			echo("FuncGuide.getValueByKey id2 not found ",id2);
		end 
		return nil;
	end 

	local value = t2[tostring(key)]

	if value == nil then 
		-- echo("FuncGuide.getValueByKey key not found " .. key);
		return nil;
	end 

	return value;
end

function FuncGuide.getUnlockGuideValueByKey(id1, key)
	local t1 = unlockGuide[tostring(id1)];
	if t1 == nil then 
		echo("FuncGuide.getUnlockGuideValueByKey id1 not found " .. id1);
		return nil;
	end 

	local value = t1[tostring(key)];

	if value == nil then 
		return nil;
	end 

	return value;
end
-- 获取箭头相关参数
function FuncGuide.getArrowInfo(groupId, step)
	return FuncGuide.getValueByKey(groupId, step, "arrow", false);
end

function FuncGuide.isNeedArrow(groupId, step)
	local pos = FuncGuide.getArrowInfo(groupId, step)

	if pos ~= nil then 
		return true
	else 
		return false
	end 
end

--[[
	是否有强制引导区域
	配了位置就认为有
]]
function FuncGuide.isNeedMask(groupId, step)
	local pos = FuncGuide.getClickPos(groupId, step)

	if pos ~= nil then 
		return true
	else 
		return false
	end
end

--得到延迟时间
function FuncGuide.getDelayByFrame( groupId, step )
	--默认10帧
	local defaultDelay = 5;
	local delay = FuncGuide.getValueByKey(groupId, step, "delay", false);
	return delay or defaultDelay;
end

function FuncGuide.getFinishMessage(groupId, step)
	local message = FuncGuide.getValueByKey(groupId, step, "finishMessage");
	return message;
end

function FuncGuide.getFallBackStep(groupId, step)
	local fallBackStep = FuncGuide.getValueByKey(groupId, step, "fallBackStep");
	return fallBackStep
end

--得到第一个强制引导的id
function FuncGuide.getLoginInFisrtForceGuideId()
	for id, v in pairs(unlockGuide) do
		if v.condition == FuncGuide.GuideCondition.LOGIN then 
			return id;
		end 
	end

	echo("-----error: getLoginInFisrtForceGuideId is nil!!!!-----");

	return nil;
end

--得到序章引导的第一个id


--从系统名字得到引导id
function FuncGuide.getUnlockGuideIdBySystemName(systemName)
	for id, v in pairs(unlockGuide) do
		if v.openValue == systemName then 
			return id;
		end 
	end

	return nil;
end

-- 检查某个引导id是否需要显示对应的功能开启动画
function FuncGuide.isShowSystemOpenById( id )
	local sysname = FuncGuide.getUnlockGuideValueByKey(id, "openValue")
	local openShow = FuncCommon.getSysOpenValue(sysname, "sysOpenShow")
	-- 先返回true
	return (openShow == 1), sysname
	-- return isShow == 1 
end

--测试某个step是否存在，用来判断是不是最后一步引导
function FuncGuide.checkIsStepExist(groundId, step)
	local t1 = funcGuide[tostring(groundId)];
	if t1 == nil then 
		return false;
	end 

	local t2 = t1[tostring(step)];
	if t2 == nil then 
		return false;
	end 

	return true;
end

function FuncGuide.getBeginGroupId(id)
	-- echo("--id--", id)
	local groupId = FuncGuide.getUnlockGuideValueByKey(id, "beginGroupId");
	-- echo("--groupId--", groupId)
	
	return tonumber(groupId);
end

function FuncGuide.getOtherInfo(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "otherInfo");
end

function FuncGuide.getWinName(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "Currentinterface");
end

function FuncGuide.getToCenterId(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "toCenterId");
end

function FuncGuide.getBattleToCenterId(step)
	return FuncGuide.getBattleValueByKey(step, "toCenterId")
end

function FuncGuide.getParameter(groundId, step)
return FuncGuide.getValueByKey(groundId, step, "parameter");
end

function FuncGuide.getLast(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "last");
end

function FuncGuide.getKeypoint(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "keypoint");
end


function FuncGuide.isGroundExist(groundId)
	local t1 = funcGuide[tostring(groundId)];

	if t1 == nil then 
		return false;
	end 
	return true;
end

function FuncGuide.getPlotId(groundId, step)
	local plotId = FuncGuide.getValueByKey(groundId, step, "plotid");
	return plotId;
end

function FuncGuide.getSuffixPlotId(groundId, step)
	local plotId = FuncGuide.getValueByKey(groundId, step, "suffixPlotid", false);
	return plotId;
end

function FuncGuide.getPreTips(groundId, step)
	local tips = FuncGuide.getValueByKey(groundId, step, "preTips");
	return tips
end

function FuncGuide.getSuffixTips(groundId, step)
	local tips = FuncGuide.getValueByKey(groundId, step, "suffixTips");
	return tips
end

function FuncGuide.getRect(groundId, step)
	local t = FuncGuide.getValueByKey(groundId, step, "Rect");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncGuide.getTouchRect(groundId, step)
	local t = FuncGuide.getValueByKey(groundId, step, "touchRect");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncGuide.getClickPos(groundId, step)
	local t = FuncGuide.getValueByKey(groundId, step, "origin", false);
	if t == nil then 
		return nil;
	else 
		return {tonumber(t[1]), tonumber(t[2])};
	end 
end

function FuncGuide.getAdaptation(groundId, step)
	local adaptation = FuncGuide.getValueByKey(groundId, step, "Adaptation");

	if adaptation == nil then 
		return 0, 0;
	else 
		--  withNotch 0表示不偏移刘海区域, 默认为0,  1表示向右深入刘海区域, -1表示向左深入刘海区 ,这个针对新手引导适配场景的点击区域, 特殊组件也可以使用
		local withNotch = 0;
		if adaptation[3] ~= nil then 
			withNotch = tonumber(adaptation[3]);
		end 

		return tonumber(adaptation[1]), tonumber(adaptation[2]), withNotch
	end 
end

function FuncGuide.getNPCAdaptation(groupId, step)
	local adaptation = FuncGuide.getValueByKey(groupId, step, "npcAdaptation");
	
	if adaptation == nil then 
		return 0, 0;
	else 
		local scaleX = 1;
		if adaptation[3] ~= nil then 
			scaleX = tonumber(adaptation[3]);
		end 
		local scaleY = 1;

		if adaptation[4] ~= nil then 
			scaleX = tonumber(adaptation[4]);
		end 
		return tonumber(adaptation[1]), tonumber(adaptation[2]), scaleX, scaleY;
	end
end

-- 战斗内也加入UI适配
function FuncGuide.getBattleAdaptation(step)
	local adaptation = FuncGuide.getBattleValueByKey(step, "Adaptation")
	if adaptation == nil then 
		return nil
	else 
		local scaleX = 1;
		if adaptation[3] ~= nil then 
			scaleX = tonumber(adaptation[3]);
		end 
		local scaleY = 1;

		if adaptation[4] ~= nil then 
			scaleX = tonumber(adaptation[4]);
		end 
		return tonumber(adaptation[1]), tonumber(adaptation[2]), scaleX, scaleY;
	end
end

function FuncGuide.getHongKuiSkinInfo()
	return {
		npc = "c_2",
		scale = 1,
		x = 0,
		y = 0
	}
end

function FuncGuide.getNpcskin(groundId, step)
	local skinInfo = FuncGuide.getValueByKey(groundId, step, "npcskin");
	
	if skinInfo then
		skinInfo.npc = skinInfo[1] or "c_1" -- 默认用蓝葵
		skinInfo.way = tonumber(skinInfo[2] or 1)  -- 默认左侧
		skinInfo.scale = tonumber(skinInfo[3] or 100) / 100
		skinInfo.x = skinInfo[4] or 0
		skinInfo.y = skinInfo[5] or 0
	end

	return skinInfo
end

function FuncGuide.getBattleNpcskin( step )
	local skinInfo = FuncGuide.getBattleValueByKey(step, "npcskin", false)
	
	if skinInfo then
		skinInfo.npc = skinInfo[1] or "c_1" -- 默认用蓝葵
		skinInfo.way = tonumber(skinInfo[2] or 1)  -- 默认左侧
		skinInfo.scale = tonumber(skinInfo[3] or 100) / 100
		skinInfo.x = skinInfo[4] or 0
		skinInfo.y = skinInfo[5] or 0
	end

	return skinInfo
end

function FuncGuide.getTextcontentIndex(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "TextcontentIndex");
end

function FuncGuide.getWrongTextcontentIndex(groundId, step)
	local result = FuncGuide.getValueByKey(groundId, step, "WrongTextcontentIndex")
	if not result then
		-- echoError("找引导策划,NoviceGuide %s,%s 没有配置 WrongTextcontentIndex 字段",groundId,step)
	end
	return result
end

function FuncGuide.getNpcPos(groundId, step)
	local t = FuncGuide.getValueByKey(groundId, step, "npcorigin");
	if t ~= nil then  
		return {tonumber(t[1]), tonumber(t[2])};
	else 
		return nil;
	end 
end

function FuncGuide.getUnlockJump(unlockId)
	return tonumber(FuncGuide.getUnlockGuideValueByKey(unlockId, "jump") or 0) == 1
end

function FuncGuide.getLineRotation(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "lineRotation") or 0;
end

function FuncGuide.getArrowDirection(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "rotation") or 0;
end

function FuncGuide.getBattleArrowDirection(step)
	return FuncGuide.getBattleValueByKey(step, "rotation") or 0
end
-- 暂时废弃2017.7.6
-- function FuncGuide.getMaskskin(groundId, step)
-- 	return FuncGuide.getValueByKey(groundId, step, "Maskskin") or "0";
-- end

function FuncGuide.getTime(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "time");
end

function FuncGuide.getMode(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "mode");
end

function FuncGuide.getBubblePosition(groundId, step)
	return FuncGuide.getValueByKey(groundId, 
		step, "BubblePosition");
end

function FuncGuide.getBubbleStr(groundId, step)
	local tid = FuncGuide.getValueByKey(groundId, step, "BubblePromptn");
	return GameConfig.getLanguage(tid); 
end

function FuncGuide.getBubbleDirection(groundId, step)
	local dir = FuncGuide.getValueByKey(groundId, step, "BubbleDirection");
	return dir == nil and "1" or dir;
end
-- 没用了，废弃
function FuncGuide.getCameraPosX(groundId, step)
	local posX = FuncGuide.getValueByKey(groundId, step, "cameraPosX");
	return posX;
end

function FuncGuide.getConditionorigin(groundId, step)
	local conditionorigin = FuncGuide.getValueByKey(groundId, step, "conditionorigin");
	return conditionorigin;
end



function FuncGuide.getBattleValueByKey(id1, key, isShowError)
	if isShowError == nil then 
		isShowError = true;
	end 
	local t1 = battleGuide[tostring(id1)];
	if t1 == nil then 
		if isShowError == true then 
			echo("FuncGuide.getBattleValueByKey id1 not found " .. id1);
		end 
		return nil;
	end 

	local value = t1[tostring(key)];

	if value == nil then 
		-- echo("FuncGuide.getBattleValueByKey key not found " .. key);
		return nil;
	end 

	return value;
end

function FuncGuide.getBattleRect(step)
	local t = FuncGuide.getBattleValueByKey(step, "Rect");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncGuide.getBattleTouchRect(step)
	local t = FuncGuide.getBattleValueByKey(step, "touchRect");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncGuide.getBattleClickPos( step )
	local t = FuncGuide.getBattleValueByKey( step, "origin" );
	return {x = tonumber(t[1]), y = tonumber(t[2])};
end

function FuncGuide.getBattleMode(step)
	local mode = FuncGuide.getBattleValueByKey(step, "mode", false);
	return mode
end

function FuncGuide.getBattleNpcPos( step )
	local t = FuncGuide.getBattleValueByKey(step, "npcorigin");
	if t ~= nil then  
		return {tonumber(t[1]), tonumber(t[2])};
	else 
		return nil;
	end 
end

function FuncGuide.getBattleLineRotation(step)
	return FuncGuide.getBattleValueByKey(step, "lineRotation") or 0
end

function FuncGuide.getBattleWrongPos( step )
	local t = FuncGuide.getBattleValueByKey(step, "wrongPos", false);
	if t ~= nil then  
		return {tonumber(t[1]), tonumber(t[2])};
	else 
		return nil;
	end 
end

function FuncGuide.getBattleTextcontentIndex( step )
	return FuncGuide.getBattleValueByKey(step, "TextcontentIndex");

end

function FuncGuide.getBattleWrongTextcontentIndex(step)
	local result = FuncGuide.getBattleValueByKey(step, "WrongTextcontentIndex")
	if not result then
		-- echoError("找引导策划,BattleGuide %s 没有配置 WrongTextcontentIndex 字段",step)
	end
	return result
end

function FuncGuide.getBattleFullMask(step)
	return FuncGuide.getBattleValueByKey(step, "fullMask") == 1
end

--是不是要跳过此步引导
function FuncGuide.isSkipStep( groupId, step )
	local isSkip = FuncGuide.getValueByKey(groupId, step, "isSkipDoAgain", true);
	if isSkip == 1 then 
		return true;
	else 
		return false;
	end 
end

function FuncGuide.getWrongPos( groupId, step )
	local t = FuncGuide.getValueByKey(groupId, step, "wrongPos", false);
	if t ~= nil then  
		return {tonumber(t[1]), tonumber(t[2])};
	else 
		return nil;
	end 
end

function FuncGuide.getIsServerConnect( groupId, step )
	local isConnect = FuncGuide.getValueByKey(groupId, step, "isServerConnect", true);

	local isKeyPoint = FuncGuide.getKeypoint(groupId, step);

	if isConnect ~= nil or isKeyPoint == 1 then 
		return true;
	else 
		return false;
	end 
end

--是不是已经超过了关键点
function FuncGuide.isOverKeyPoint(groupId, step)
	if step == 1 then 
		return false;
	end 

	for i = 1, tonumber(step) - 1 do
		local isKey = FuncGuide.getValueByKey(groupId, i, "keypoint", true);
		if isKey == 1 then 	 
			return true;
		end
	end
	return false;
end


function FuncGuide.getLastStep(groupId)
	local index = 1;
	while FuncGuide.checkIsStepExist(groupId, index) == true do
		index = index + 1;
	end
	return index - 1;
end


function FuncGuide.isNeedJumpToHomeWhenSysOpen(names)
	for k, openSysName in pairs(names) do
		local unlockId = FuncGuide.getUnlockGuideIdBySystemName(openSysName);
		-- 这一步触发后是否跳转
		if unlockId and FuncGuide.getUnlockJump(unlockId) then 
			return true;
		end
	end
	return false;
end

function FuncGuide.isBattleHaveLine( step )
	return FuncGuide.getBattleValueByKey(step, "isHaveLine", false);
end

function FuncGuide.isBattleNeedArrow( step )
	local pos = FuncGuide.getBattleArrowInfo(step)

	if pos ~= nil then 
		return true
	else 
		return false
	end 
end

function FuncGuide.isHaveLine( groundId, step )
	return FuncGuide.getValueByKey(groundId, step, "isHaveLine", false);
end

function FuncGuide.getBattleArrowInfo(step)
	return FuncGuide.getBattleValueByKey(step, "arrow", false);
end
-- 废弃
function FuncGuide.getLinePos( step )
	local t = FuncGuide.getBattleValueByKey(step, "linePos", false);
	if t ~= nil then  
		return {tonumber(t[1]), tonumber(t[2])};
	else 
		return nil;
	end 
end

function FuncGuide.isWaitBattleMessage( step )
	local mode = FuncGuide.getBattleValueByKey(step, "mode", false);
	
	if mode == "2" then 
		return true;
	else
		return false;
	end 
	
end

function FuncGuide.getOpenPriorityBySysname( sysName )
	local unlockId = FuncGuide.getUnlockGuideIdBySystemName(sysName)
	local priority = math.huge
	if not unlockId then
		echo("%s 功能没有配置开启的引导,给个最低优先级", sysName)
	else
		priority = FuncGuide.getUnlockGuideValueByKey(unlockId, "priority")
	end

	return priority
end

function FuncGuide.getOpenPriorityById( unlockId )
	local priority = FuncGuide.getUnlockGuideValueByKey(unlockId, "priority")
	-- 不填默认优先级最低
	if not priority then
		echoWarn("unlockId %s 未配置开启优先级，默认为最低", unlockId)
		priority = math.huge
	end

	return priority
end

function FuncGuide.getJump(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "jump")
end

function FuncGuide.getPerJumpPlot(unlockId)
	local groupId = FuncGuide.getBeginGroupId(unlockId)
	return FuncGuide.getValueByKey(groupId, 1, "perJumpPlot")
end

function FuncGuide.getEntranceName(groundId, step)
	return FuncGuide.getValueByKey(groundId, step, "entranceName")
end

-- 获取战斗结束消息
function FuncGuide.getBattleFinishMessage(step)
	return FuncGuide.getBattleValueByKey(step, "message", false)
end

-- 获取人物Hid
function FuncGuide.getBattleHeroHid(step)
	return FuncGuide.getBattleValueByKey(step, "heroHid", false)
end

-- 战斗某一步是否需要强调
function FuncGuide.isBattleRectNeedStress(step)
	return FuncGuide.getBattleValueByKey(step, "stressEff", false) == 1
end

-- 判断当前关卡是否存在强制引导
function FuncGuide.hasBattleGuide(levelId)
	-- 关引导不判断
	if IS_CLOSE_TURORIAL and DEBUG_SKIP_PROLOGURE then return false end

	if DEBUG_SERVICES then return false end
	-- 特殊功能需要判断初次
	local flag = true
	-- 登仙台
	if tostring(levelId) == Fight.xvzhangParams.pvp then
		local firstPvp = tonumber(LS:prv():get(StorageCode.tutorial_first_pvp,0))
		flag = (firstPvp == 0)
	end

	if tostring(levelId) == Fight.xvzhangParams.trial then
		local firstTrial =  tonumber(LS:prv():get(StorageCode.tutorial_first_trial,0))
		flag = (firstTrial == 0)
	end

	return not (battleProcess[tostring(levelId)] == nil) and flag
end

-- 是否屏蔽战斗内所有点击
function FuncGuide.isDisableBattleClick( step )
	return FuncGuide.getBattleMode(step) == "1" 
end

-- 获取换位参数
function FuncGuide.getChangePos(step)
	return FuncGuide.getBattleValueByKey(step, "changePos", false)
end

-- 获取完成后是否重置倒计时
function FuncGuide.isResetCountDown(step)
	return FuncGuide.getBattleValueByKey(step, "resetCountDown", false) == 1
end

-- 获取完成后是否继续战斗
function FuncGuide.isContinueFight(step)
	return FuncGuide.getBattleValueByKey(step, "continueFight", false) == 1
end

-- 查找步骤（由回合关系触发）
-- key -> wave_camp_round_afterAtk
function FuncGuide.getBattleProcessStepByRound(levelId, key)
	local levelInfo = battleProcess[tostring(levelId)]
	if levelInfo then
		for _,info in pairs(levelInfo) do
			if info.stype == 1 then
				local trigger = info.trigger
				local wave = tostring(trigger[1])
				local camp = tostring(trigger[3])
				local round = tostring(trigger[2])
				local afterAtk = tostring(trigger[4])
				local tKey = wave .. camp .. round .. afterAtk
				-- echo("排查问题",tKey)
				if tKey == key then
					return info.step,table.copy(info.followup or {})
				end
			end
		end
	end

	return false
end

-- 查找步骤（由步骤结束触发）
-- key -> step
function FuncGuide.getBattleProcessStepByStepFinish(levelId, key)
	local levelInfo = battleProcess[tostring(levelId)]
	if levelInfo then
		for _,info in pairs(levelInfo) do
			if info.stype == 2 then
				local trigger = info.trigger
				local lastStep = trigger[1]
				if tonumber(lastStep) == tonumber(key) then
					return info.step,table.copy(info.followup or {})
				end
			end
		end
	end

	return false
end

-- 判断当前关卡是否存在弱引导
function FuncGuide.hasBattleWeakGuide(levelId)
	-- 关引导不判断
	if IS_CLOSE_TURORIAL then return false end

	if DEBUG_SERVICES then return false end

	if not levelId then return false end

	return not (battleWeakGuide[tostring(levelId)] == nil)
end

-- 根据类型和key查找步骤
-- key -> wave..round..gType
-- gType弱引导类型（布阵还是放大招）
function FuncGuide.getBattleWeakStepByKey(levelId, key)
	local levelInfo = battleWeakGuide[tostring(levelId)]
	if levelInfo then
		for _,info in pairs(levelInfo) do
			local wave = tostring(info.wave or 0)
			local round = tostring(info.round or 0)
			local gtype = tostring(info.gtype or 1)
			local tKey = string.format("%s%s%s",wave,round,gtype)

			if tKey == key then
				return info.step
			end
		end
	end

	return false
end

-- 引导视频表
function FuncGuide.getVideoDataByIdAndKey(id,key)
	local data = FuncGuide.getVideoDataById(id)
	if data[key] then
		return data[key]
	else
		echoError("videoGuide表id == ",id," 中未找到key == ",key)
		return nil	
	end
end

function FuncGuide.getVideoDataById(id)
	id = tostring(id)
	local data = videoGuide[id]
	if data then
		return data
	else
		echoError("videoGuide表未找到此id == ",id,"用默认的 1")
		return videoGuide[1]
	end
end

-- 获取前置入口
function FuncGuide.getPreEntranceById(id)
	return FuncGuide.getUnlockGuideValueByKey(id, "preEntrance")
end
------------------------------------------------------------------------
---------------------------奇侠唤醒相关---------------------------------
------------------------------------------------------------------------
function FuncGuide.getAwakenData( )
	return partnerAwaken
end
function FuncGuide.getAwakenDataById( id )
	id = tostring(id)
	local data = partnerAwaken[id]
	if data then
		return data
	else
		echoError("Awaken表未找到此id == ",id,"用默认的 101")
		return partnerAwaken[101]
	end
end
function FuncGuide.getAwakenDataByIdAndKey(id,key)
	local data = FuncGuide.getAwakenDataById( id )
	if data[key] then
		return data[key]
	else
		echoError("Awaken表id == ",id," 中未找到key == ",key)
		return nil	
	end
end
function FuncGuide.getAwakenPartner(id)
	return FuncGuide.getAwakenDataByIdAndKey(id,"partnerId")
end
function FuncGuide.getAwakenType(id)
	return tonumber(FuncGuide.getAwakenDataByIdAndKey(id,"puzzle"))
end
function FuncGuide.getAwakenOrder(id)
	return FuncGuide.getAwakenDataByIdAndKey(id,"order")
end
function FuncGuide.getAwakenNameSpr(id)
	return FuncGuide.getAwakenDataByIdAndKey(id,"partnerName")
end
function FuncGuide.getAwakenStory(id)
	return FuncGuide.getAwakenDataByIdAndKey(id,"copy")
end
function FuncGuide.getAwakenMaxStory(id)
	return FuncGuide.getAwakenDataByIdAndKey(id,"awaken")
end
function FuncGuide.getAwakenPinTu(id)
	return FuncGuide.getAwakenDataByIdAndKey(id,"somePuzzle")
end
function FuncGuide.getAwakenMiaoshu(id)
	local tips = FuncGuide.getAwakenDataByIdAndKey(id,"location")
	return GameConfig.getLanguage(tips)
end
function FuncGuide.getAwakenMode(id)
	local mold = FuncGuide.getAwakenDataByIdAndKey(id,"mold")
	return mold
end
function FuncGuide.getAllAwakenByPartnerId( parnterId )
	local T = {}
	for i ,v in pairs(partnerAwaken) do
		if tostring(v.partnerId) == tostring(parnterId) then
			table.insert(T, v)
		end
	end
	return T
end