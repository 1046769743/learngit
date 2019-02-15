--
-- Author: ZhangYanguang
-- Date: 2016-03-07
-- world系统数据类
--[[
	chapters = {
		101 = {
			id = 101,
			bonus1 = 1,
			bonus2 = 1,
			bonus3 = 1,
			stages =  {"10103" = 5},
		}
	}

]]
local WorldModel = class("WorldModel",BaseModel)

function WorldModel:init(d)
	self.modelName = "world"
	WorldModel.super.init(self, d)
	
	self:initData()
	self:registerEvent()
end

function WorldModel:initData()
	-- 战斗结果最大值
	self.maxBattleRt = 7
	
	self.arabMap = {
		[0] = "十",
		[1] = "一",
		[2] = "二",
		[3] = "三",
		[4] = "四",
		[5] = "五",
		[6] = "六",
		[7] = "七",
		[8] = "八",
		[9] = "九",
	}
	
	self.sweepType = {
		-- 扫荡1次
		SWEEP_ONE = 1,
		-- 扫荡10次
		SWEEP_TEN = 10
	}

	self.stageType = FuncChapter.stageType

	self.activity = {
		-- 副本掉落次数
		ACTIVITY_DROP_TIMES = 605
	}

	self.stageScore = {
		SCORE_LOCK = 0, 			--未解锁的成绩为0
		SCORE_ONE_STAR = 1,			--一星
		SCORE_TWO_STAR = 2,			--二星
		SCORE_THREE_STAR = 3, 		--三星
	}

	self.starBoxStatus = {
		STATUS_NOT_ENOUGH = 0,  --不足
		STATUS_ENOUGH = 1, 		--足够，未领取
		STATUS_USED = 2,		--已领取
	}

	self.storyStatus = {
		STATUS_LOCK = 1,  		--锁定
		STATUS_UNLOCK = 2, 		--解锁
		STATUS_PASS = 3,		--通关
	}

	self.kind = {
		KIND_NORMAL = 1,		--普通关卡
		KIND_ELITE = 2,			--额外宝箱关卡
		KIND_BOSS = 3			--boss关卡
	}

	-- 序章storyID
	self.prologueStoryId = 100

	-- 章分组数据缓存
	self.groupListCache = {}

	-- 缓存用户数据
	UserModel:cacheUserData()
	
	if not PrologueUtils:showPrologue() then
		self:sendRedStatusMsg()
	end
	self.shopType = {}
end

--更新数据
function WorldModel:updateData(data)
	WorldModel.super.updateData(self,data);
	if data.chapters ~= nil then
        for k,v in pairs(data.chapters) do
            if v.stages ~= nil then
                EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_UPDATE, {data.chapters}); 
            end
        end
    end
    
end

--删除数据
function WorldModel:deleteData( data ) 
	WorldModel.super.deleteData(self,data);
	if data.chapters ~= nil then
        -- 从非特等变化为特等消息
        for k,v in pairs(data.chapters) do
            if type(v) == "table" and v.stages ~= nil then
                EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_DELETE, {data.chapters}); 
            end
        end
    end
end

function WorldModel:registerEvent()
	-- 商店开启消息
    EventControler:addEventListener(ShopEvent.SHOPEVENT_TEMP_SHOP_OPEN,self.onOpenShop,self)
    -- 开启宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.sendRedStatusMsg, self)
    -- 开启额外宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES, self.sendRedStatusMsg, self)
    -- 关卡进度变化
    EventControler:addEventListener(WorldEvent.WORLDEVENT_CHAPTER_STAGE_SCORE_UPDATE, self.sendRedStatusMsg, self)
    -- 等级变化
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.sendRedStatusMsg, self)
    -- 情景卡红点
    EventControler:addEventListener(MemoryEvent.MEMORY_CARD_RED_EVENT, self.sendRedStatusMsg, self)
    -- 精英首次通关
    EventControler:addEventListener(EliteEvent.ELITE_FIRST_PASS_RAID, self.passNewRaid, self)
end

function WorldModel:passNewRaid( event )
	local raidId = event.params.raidId
	echo("!!!!!!!!!_____ raidId",raidId)
	self.newPassRaid = raidId
end
function WorldModel:getEliteNewPassRaid()
	local raidId = self.newPassRaid 
	if self.newPassRaid then
		self.newPassRaid = nil
	end
	return raidId
end
-- 发送小红点状态消息
function WorldModel:sendRedStatusMsg()
	--[[
	local isShowRedPoint = self:hasStarBoxes() or self:hasExtraBoxes()
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT
			, {redPointType = HomeModel.REDPOINT.DOWNBTN.WORLD, isShow = isShowRedPoint})
	]]

	-- 往主城发送红点状态
	local isShowMainRedPoint = self:showMainRedPoint()
						-- or self:showMemoryRedPoint() 
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT
			, {redPointType = HomeModel.REDPOINT.DOWNBTN.CHALLENGE, isShow = isShowMainRedPoint})  ---发送到历练按钮上

	local isShowEliteRedPoint = self:showEliteRedPoint()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT
			, {redPointType = HomeModel.REDPOINT.DOWNBTN.ELITE, isShow = isShowEliteRedPoint})
end

-- 是否显示旧的回忆红点
function WorldModel:showMainRedPoint()
	-- local isShowRedPoint = self:hasStarBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_MAIN)
	-- 	or self:hasExtraBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_MAIN)
	-- modify by ZhangYanguang 红点状态不考虑额外宝箱
	local isShowRedPoint = self:hasStarBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_MAIN)
		--or TeamFormationModel:hasIdlePosition()
	return isShowRedPoint
end

-- 是否显示精英红点
function WorldModel:showEliteRedPoint()
	local isShowRedPoint = self:hasStarBoxesByStageType(WorldModel.stageType.TYPE_STAGE_ELITE) 
	    	or self:hasExtraBoxesByStageType(WorldModel.stageType.TYPE_STAGE_ELITE)
	return isShowRedPoint
end

-- 是否显示情景卡红点
function WorldModel:showMemoryRedPoint()
	local isShowRedPoint = MemoryCardModel:checkRedPointShow()
	return isShowRedPoint
end

-- 保存主角在地图上位置
function WorldModel:saveCharMapInfo(charMapPos,charScaleX,charFace)
	LS:prv():set(StorageCode.world_char_info,json.encode({x=charMapPos.x,y=charMapPos.y,charScaleX=charScaleX,charFace=charFace}))
end

function WorldModel:getCharMapInfo()
	local infoJson = LS:prv():get(StorageCode.world_char_info,"")
	if infoJson and infoJson ~= "" then
		local info = json.decode(infoJson)
		return info
	else
		return nil
	end
end

function WorldModel:clearCharMapPos()
	self.charMapPos = nil
end

function WorldModel:setCurStageType(stageType)
	self.curStageType = stageType
end

function WorldModel:getCurStageType()
	return self.curStageType
end

-- 临时商店开启
function WorldModel:onOpenShop(event)
	table.insert(self.shopType, event.params.shopType)
end

function WorldModel:getOpenShopType()
	return self.shopType
end

-- 战斗前重置状态
function WorldModel:resetDataBeforeBattle()
	self.shopType = {}
end

-- 保存当前战斗PVE 信息
function WorldModel:setCurPVEBattleInfo(battleInfo)
	self.curPVEBattleInfo = battleInfo
end

-- 获取当前战斗PVE RaidId
function WorldModel:getCurPVEBattleInfo()
	return self.curPVEBattleInfo
end

-- 是否是最后一章
function WorldModel:isLastChapter(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local chapter = storyData.chapter
	local chapterType = storyData.type

	local allStoryData = FuncChapter.getStoryData()
	for k,v in pairs(allStoryData) do
		if v.type == chapterType then
			if tonumber(v.chapter) > tonumber(chapter) then
				return false
			end
		end
	end

	return true
end

-- 是否是最后一节
function WorldModel:isLastRaidId(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	if raidData == nil then
		return false
	end
	-- 第几节
	local curSection = raidData.section

	local storyId = raidData.chapter
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local totalSection = storyData.section

	if tonumber(curSection) == tonumber(totalSection) then
		return true
	else
		return false
	end
end

-- 是否是第一章
function WorldModel:isFirstChapter(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	return storyData.chapter == 1
end

-- 通过副本类型和章索引获取storyID
function WorldModel:getStoryIdByTypeAndChapter(stageType,chapter)
	local allStoryData = FuncChapter.getStoryData()
	for k,v in pairs(allStoryData) do
		if tonumber(v.type) == tonumber(stageType) and tonumber(v.chapter) ==  tonumber(chapter) then
			return k
		end
	end

	return nil
end

-- 获取下一个PVE id
-- 1.当前通关的最大关卡，有宝箱且没领取
-- 2.下一个关卡，无论是否解锁
function WorldModel:getNextMainRaidId()
	return self:getNextPVERaidId(self.stageType.TYPE_STAGE_MAIN)
end

-- 获取pve下一个解锁的节点（已经解锁）
function WorldModel:getPVENextRaidId(stageType)
	local raidId = self:getNextUnLockRaidId(stageType)
	return raidId
end

-- 获取已经解锁的最大GVEid
function WorldModel:getMaxUnLockEliteRaidId()
	return self:getNextUnLockRaidId(FuncChapter.stageType.TYPE_STAGE_ELITE)
end

-- 获取已经解锁的最大PVE id
function WorldModel:getMaxUnLockMainRaidId()
	return self:getNextUnLockRaidId(FuncChapter.stageType.TYPE_STAGE_MAIN)
end

function WorldModel:getUnLockMaxRaidId(stageType)
	if stageType == FuncChapter.stageType.TYPE_STAGE_MAIN then
		return self:getMaxUnLockMainRaidId()
	elseif stageType == FuncChapter.stageType.TYPE_STAGE_ELITE then
		return self:getMaxUnLockEliteRaidId()
	end
end

-- 获取指定章解锁的最大raidId
function WorldModel:getUnLockMaxRaidIdByStoryId(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local unLockMaxRaidId = self:getUnLockMaxRaidId(storyData.type)

	local lastRaidId = FuncChapter.getLastRaidIdByStoryId(storyId)
	if tostring(unLockMaxRaidId) > tostring(lastRaidId) then
		return lastRaidId
	else
		return unLockMaxRaidId
	end
end

-- 获取PV已完成节点的下一个raidId，无论是否解锁
function WorldModel:getNextPVERaidId(stageType)
	local unLockMaxRaidId = nil
	local passMaxRaidId = nil
	if stageType == FuncChapter.stageType.TYPE_STAGE_MAIN then
		unLockMaxRaidId = self:getMaxUnLockMainRaidId()
		passMaxRaidId = UserExtModel:getMainStageId()
	elseif stageType == FuncChapter.stageType.TYPE_STAGE_ELITE then
		unLockMaxRaidId = self:getMaxUnLockEliteRaidId()
		passMaxRaidId = UserExtModel:getEliteStageId()
	end

	local nextRaidId = unLockMaxRaidId

	-- 解锁的最大节点已经完成
	if tonumber(unLockMaxRaidId) == tonumber(passMaxRaidId) then
		nextRaidId = self:getNextRaidIdById(unLockMaxRaidId)
	end

	return nextRaidId
end

-- 获取一章内下一个节点，无论是否解锁
-- new world
-- 如果当raidId是章内最后一个，返回nil
function WorldModel:getNextRaidInStory(raidId)
	local curRaidData = FuncChapter.getRaidDataByRaidId(raidId)
	local curSection = curRaidData.section
	local curChapter = curRaidData.chapter

	local nextRaidId = nil
	local maxSection = FuncChapter.getMaxSectionByStoryId(curChapter)
	if tonumber(curSection) < tonumber(maxSection) then
		nextRaidId = tonumber(raidId) + 1
	end

	return nextRaidId
end

-- 获取其下一个节点，无论是否解锁
function WorldModel:getNextRaidIdById(raidId)
	local curRaidData = FuncChapter.getRaidDataByRaidId(raidId)
	local curSection = curRaidData.section
	local curChapter = curRaidData.chapter

	local nextRaidId = raidId
	local maxSection = FuncChapter.getMaxSectionByStoryId(curChapter)
	if tonumber(curSection) < tonumber(maxSection) then
		nextRaidId = tonumber(raidId) + 1
	else
		local nextStory = tonumber(curChapter) + 1
		local storyData = FuncChapter.getStoryDataByStoryId(nextStory)
		if storyData ~= nil then
			-- 获取下一章的第一节
			nextRaidId = FuncChapter.getRaidIdByStoryId(nextStory,1)
		end
	end

	return nextRaidId
end

-- 获取上一个节点，无论是否解锁
-- 比raidId小的最大RaidID
function WorldModel:getLastRaidIdById(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local allRaidData = FuncChapter.getRaidData()
	local lastRaidId = nil

	for k,v in pairs(allRaidData) do
		if v.type == raidData.type and k < tostring(raidId) then
			if lastRaidId == nil then
				lastRaidId = k
			else
				if k > lastRaidId then
					lastRaidId = k
				end
			end
		end
	end

	return lastRaidId
end

-- 根据stageType获取下一个已解锁的raidId
function WorldModel:getNextUnLockRaidId(stageType)
	local raidId = nil
	local nextRaidId = nil

	if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
        raidId = UserExtModel:getMainStageId()
    elseif tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_ELITE then
        raidId = UserExtModel:getEliteStageId()
    end

    if raidId == 0 then
    	raidId = self:getFirstRaidId(stageType)
    else
    	local storyId = FuncChapter.getStoryIdByRaidId(raidId)
    	local maxSection = FuncChapter.getMaxSectionByStoryId(storyId)
    	local curSection = FuncChapter.getRaidAttrByKey(raidId,"section")

    	if curSection ~= nil and maxSection ~= nil then
    		local nextSection = nil
	    	if tonumber(curSection) >= tonumber(maxSection) then
	    		nextSection = maxSection
	    		if not self:isLastChapter(storyId) then
	    			local nextStoryId = storyId + 1
	    			-- 开启下一章第一节
	    			raidId = FuncChapter.getRaidIdByStoryId(nextStoryId,1)
	    		end
	    	else
	    		nextSection = curSection + 1
	    		raidId = FuncChapter.getRaidIdByStoryId(storyId,nextSection)
	    	end
    	else
    		echoError("WorldModel:getNextUnLockRaidId stageType=",stageType,raidId,storyId,curSection,maxSection)
    	end
    end

    if raidId == 0 then
    	nextRaidId = 0
    else
    	if self:isRaidLock(raidId) then
    		if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
		        nextRaidId = UserExtModel:getMainStageId()
		    elseif tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_ELITE then
		        nextRaidId = UserExtModel:getEliteStageId()
		    end
		else
			nextRaidId = raidId
    	end
    end

    if nextRaidId == nil then
    	echoError("WorldModel:getNextUnLockRaidId nextRaidId is nil")
    end

    return nextRaidId
end

-- 判断章是否开启
function WorldModel:isStoryLock(storyId)
	local firstRaidId = FuncChapter.getRaidIdByStoryId(storyId,1)
	local isLock,condition = self:isRaidLock(firstRaidId)

	local lockLevel = 1
	if condition then
		for i=1,#condition do
			local cond = condition[i]
			if cond.t == UserModel.CONDITION_TYPE.LEVEL then
				lockLevel = cond.v
				break
			end
		end
	end
	return isLock,condition,lockLevel
end

-- 判断raid是否解锁，未解锁返回解锁条件
function WorldModel:isRaidLock(raidId)
	local isLock = true

	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	if raidData == nil then
		echoError("WorldModel:isRaidLock raidId=",raidId)
		return true,nil
	end
	local condition = raidData.condition

	local rt = UserModel:checkCondition(condition)
	if rt == nil then
		isLock = false
	end
	return isLock,condition
end

-- 通过stateType，获取第一个RaidId
function WorldModel:getFirstRaidId(stageType)
	local firstStoryId = self:getFirstStoryId(stageType)
	local firstRaidId = FuncChapter.getRaidIdByStoryId(firstStoryId,1)
	return firstRaidId
end

-- 获取通关的最大RaidId
function WorldModel:getMaxPassRaidId(stageType)
	stageType = tonumber(stageType)
	local passMaxRaidId = nil
	if stageType == FuncChapter.stageType.TYPE_STAGE_MAIN then
        passMaxRaidId = UserExtModel:getMainStageId()
    elseif stageType == FuncChapter.stageType.TYPE_STAGE_ELITE then
        passMaxRaidId = UserExtModel:getEliteStageId()
    end

    return passMaxRaidId
end

-- 通过stateType，获取第一个storyID
function WorldModel:getFirstStoryId(stateType)
	local allStoryData = FuncChapter.getStoryData()
	local minStoryId = nil

	for k,v in pairs(allStoryData) do
		if v.type == stateType then
			if minStoryId == nil then
				if tonumber(k) > self.prologueStoryId then
					minStoryId = k
				end
			else
				if tonumber(k) < tonumber(minStoryId) and tonumber(k) > self.prologueStoryId then
					minStoryId = k
				end
			end
		end
	end

	return minStoryId
end

-- 获取特等星级的数量
function WorldModel:getTotalThreeStarNum(storyId)
	local stagesList = self:getMainStageList(storyId)

	local maxSection = self:getStoryMaxSection(storyId)
	local starNum = 0

	-- 如果通关
	if self:isPassStory(storyId) then
		if stagesList ~= nil then
			local length = table.length(stagesList)
			starNum = maxSection - length
		else
			starNum = maxSection
		end
	else
		-- 当前已完成的raidId
		local passMaxRaidId = nil
		local storyData = FuncChapter.getStoryDataByStoryId(storyId)
		local passMaxRaidId = self:getMaxPassRaidId(storyData.type)

		-- 一个节点都没打过
		if tonumber(passMaxRaidId) == 0 then
			return starNum
		end

		local raidData = FuncChapter.getRaidDataByRaidId(passMaxRaidId)
		local passSection = raidData.section
		local curChapter = raidData.chapter

		-- curChapter是storyId对应的上一章，storyId刚开启，一个节点都没完成
		if tonumber(curChapter) <  tonumber(storyId) then
			starNum = 0
		elseif tonumber(curChapter) ==  tonumber(storyId) then
			if stagesList ~= nil then
				local length = table.length(stagesList)
				starNum = passSection - length
			else
				starNum = passSection
			end
		end
	end

	return starNum
end

-- 获取已得star总数量
function WorldModel:getTotalStarNum(storyId)
	local starNum = 0

	local storyData = FuncChapter.getStoryDataByStoryId(storyId)

	-- 当前已完成的raidId
	local passMaxRaidId = self:getMaxPassRaidId(storyData.type)
	-- 一个节点都没打过
	if tonumber(passMaxRaidId) == 0 then
		return starNum
	end

	local raidData = FuncChapter.getRaidDataByRaidId(passMaxRaidId)
	local curChapter = raidData.chapter

	if tonumber(curChapter) >=  tonumber(storyId) then
		local allRaidData = FuncChapter.getRaidData()
		for k,v in pairs(allRaidData) do
			if tonumber(v.chapter) == tonumber(storyId) and tonumber(k) <= passMaxRaidId then
				local battleRt = self:getRaidBattleResult(tonumber(k))
				local star,_ = FuncCommon:getBattleStar(battleRt)
				-- echo("star=======")
				-- echo(star)
				-- echo(k)
				starNum = starNum + star
			end
		end
	end

	return starNum
end

-- 判断是否有未领取的星级宝箱
function WorldModel:hasStarBoxes()
	return self:hasStarBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_MAIN)
		   or self:hasStarBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_ELITE)
end

function WorldModel:hasPVEStarBoxes()
	return self:hasStarBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_MAIN)
end

function WorldModel:hasEliteStarBoxes()
	return self:hasStarBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_ELITE)
end

-- 判断是否有未领取的额外宝箱
function WorldModel:hasExtraBoxes()
	return self:hasExtraBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_MAIN)
		   or self:hasExtraBoxesByStageType(FuncChapter.stageType.TYPE_STAGE_ELITE)
end

-- 通过stageType，判断是否有未领取的星级宝箱
function WorldModel:hasStarBoxesByStageType(stageType)
	local unlockMaxStoryId = self:getUnLockMaxStoryId(stageType)
	if unlockMaxStoryId == nil then
		return false
	end

	local storyData = FuncChapter.getStoryDataByStoryId(unlockMaxStoryId)
	local chapterNum = storyData.chapter

	local result = false
	for i=0,chapterNum-1 do
		local curStoryId = unlockMaxStoryId - i
		result = self:hasStarBoxesByStoryId(curStoryId)
		if result then
			return result
		end
	end

	return result
end

-- 通过stageType，判断是否有未领取的额外宝箱
function WorldModel:hasExtraBoxesByStageType(stageType)
	local unlockMaxStoryId = self:getUnLockMaxStoryId(stageType)
	if unlockMaxStoryId == nil then
		return false
	end

	local storyData = FuncChapter.getStoryDataByStoryId(unlockMaxStoryId)
	local chapterNum = storyData.chapter

	local result = false
	for i=0,chapterNum-1 do
		local curStoryId = unlockMaxStoryId - i
		result = self:hasExtraBoxesByStoryId(curStoryId)
		if result then
			return result
		end
	end

	return result
end

-- 通过storyId，判断是否有未领取的星级宝箱
function WorldModel:hasStarBoxesByStoryId(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local storyChapter = storyData.chapter
	local bonusConArr = storyData.bonusCon

	local ownStrNum = WorldModel:getTotalStarNum(storyId)

	local result = false
	local serverChaptersData = self._data

	-- 固定3个宝箱
	for i=1,3 do
		if self:hasStarBoxByBoxIndex(storyId,i) then
			result = true
			return result
		end
	end

	return result
end

-- 通过storyId和索引，判断是否有未领取的星级宝箱
function WorldModel:hasStarBoxByBoxIndex(storyId,starIndex)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local storyChapter = storyData.chapter
	local bonusConArr = storyData.bonusCon

	local ownStrNum = WorldModel:getTotalStarNum(storyId)

	local result = false
	local serverChaptersData = self._data

	if starIndex >=1 and starIndex <= 3 then
		local needStar = bonusConArr[starIndex]
		-- 满足领取条件
		if ownStrNum >= needStar then
			-- 再判断是否已领取
			if serverChaptersData ~= nil then
				local bonusData = serverChaptersData[tostring(storyId)]
				if bonusData ~= nil then
					-- 满足，未领取
					if bonusData["bonus"..starIndex] ~= nil then
						result = true
					-- 已经领取
					else
						result = false
					end
				end
			end
		end
	end

	return result
end

-- 通过storyId，判断是否有未领取的额外宝箱
function WorldModel:hasExtraBoxesByStoryId(storyId)
	local serverChaptersData = self._data
	local result = false

	if serverChaptersData ~= nil then
		local bonusData = serverChaptersData[tostring(storyId)]
		if bonusData ~= nil then
			local extraBounusData = bonusData.extraBonus
			if extraBounusData ~= nil then
				for k,_ in pairs(extraBounusData) do
					result = true
					break
				end
			end
		end
	end

	return result
end

-- 获取星级宝箱状态
function WorldModel:getStarBoxStatus(storyId,ownStar,needStar,boxIndex)
	local status = self.starBoxStatus.STATUS_NOT_ENOUGH
	if ownStar < needStar then
		status = self.starBoxStatus.STATUS_NOT_ENOUGH
	else
		local serverChaptersData = self._data
		-- dump(serverChaptersData)
		if serverChaptersData ~= nil then
			local bonusData = serverChaptersData[tostring(storyId)]
			-- dump(bonusData)

			if bonusData ~= nil then
				-- 满足，未领取
				if bonusData["bonus"..boxIndex] ~= nil then
					status = self.starBoxStatus.STATUS_ENOUGH
				else
					status = self.starBoxStatus.STATUS_USED
				end
			else
				status = self.starBoxStatus.STATUS_USED
			end
		end
	end

	return status
end

-- todo new world
-- 是否有额外宝箱
function WorldModel:hasExtraBox(raidId)
	-- 序章没有额外宝箱
	if PrologueUtils:showPrologue() then
		return false
	end

	if not raidId then
		return false
	end

	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	return raidData.extraBonus ~= nil
end

-- todo new world
-- 是否领取了额外宝箱
function WorldModel:hasUsedExtraBox(raidId)
	-- 没有额外宝箱，返回已使用
	if not self:hasExtraBox(raidId) then
		return true
	end

	-- 没有通关，返回未使用
	if not self:isPassRaid(raidId) then
		return false
	end

	local status = self:getExtraBoxStatus(raidId)
	return status == self.starBoxStatus.STATUS_USED
end

-- 获取额外宝箱状态
function WorldModel:getExtraBoxStatus(raidId)
	local status = self.starBoxStatus.STATUS_NOT_ENOUGH

	if raidId == nil or raidId == "" then
		return status
	end

	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local storyId = raidData.chapter

	if raidData.extraBonus == nil then
		return status
	end

	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local passMaxRaidId = self:getMaxPassRaidId(storyData.type)

	-- 未通过，不可以领取
	if tostring(raidId) > tostring(passMaxRaidId) then
		return status
	else
		status = self.starBoxStatus.STATUS_ENOUGH
	end

	-- 判断是否已经领取
	local serverChaptersData = self._data
	if serverChaptersData ~= nil then
		local bonusData = serverChaptersData[tostring(storyId)]

		-- 有未领取的
		if bonusData ~= nil then
			local extraBounusData = bonusData.extraBonus
			if extraBounusData ~= nil then
				for k,v in  pairs(extraBounusData) do
					-- 还没有领取
					if tostring(k) == tostring(raidId) then
						return status
					end
				end

				-- 已经领取
				status = self.starBoxStatus.STATUS_USED
				return status
			else
				-- status = self.starBoxStatus.STATUS_NOT_ENOUGH
				status = self.starBoxStatus.STATUS_USED
			end
		else
			-- 全部领取完毕
			status = self.starBoxStatus.STATUS_USED
		end
	end

	return status
end

-- 获取关卡战斗结果值
function WorldModel:getRaidBattleResult(curRaidId)
	local raidData = FuncChapter.getRaidDataByRaidId(curRaidId)
	local storyId = raidData.chapter

	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local passMaxRaidId = self:getMaxPassRaidId(storyData.type)

	local serverChaptersData = self._data
	-- 服务器记录的各节点成绩数据，如果结果是三星,服务端会删除数据
	local stagesList = self:getMainStageList(storyId)

	local battleResult = nil
	-- 服务器没有数据，说明全是三星或者是本章一个节点都没通关
	if stagesList == nil or table.length(stagesList) <= 0 then
		-- 通过了节点，服务器没有记录，说明成绩是三星
		if tonumber(curRaidId) <= tonumber(passMaxRaidId) then
			battleResult = self.maxBattleRt
		end
	else
		if tonumber(curRaidId) > tonumber(passMaxRaidId) then
			battleResult = 0
		else
			battleResult = stagesList[tostring(curRaidId)]
			-- 通过了节点，服务器没有记录，说明打了特等
			if battleResult == nil and tonumber(curRaidId) <= tonumber(passMaxRaidId) then
				-- 战斗结果7表示是三星
				battleResult = self.maxBattleRt
			end
		end
	end

	-- 0表示没有成绩
	if battleResult == nil then
		battleResult = 0
	end

	return battleResult
end

-- 通关关卡ID，获取关卡战斗星级数据
function WorldModel:getBattleStarByRaidId(curRaidId)
	local battleResult = self:getRaidBattleResult(curRaidId)
	local star,condArr = FuncCommon:getBattleStar(battleResult)

	return star,condArr
end

-- 通过战斗结果，获取关卡战斗星级数据
function WorldModel:getBattleStar(battleResult)
	local star,condArr = FuncCommon:getBattleStar(battleResult)
	return star,condArr
end

-- 获取服务器记录的节点成绩列表
function WorldModel:getMainStageList(storyId)
	local stagesList = nil
	local serverChaptersData = self._data
	if serverChaptersData ~= nil then
		local storyChapter = serverChaptersData[tostring(storyId)]
		if storyChapter ~= nil then
			stagesList = storyChapter.stages
		end
	end

	return stagesList
end

-- 小写数字转大写数字(最大支持到99)
function WorldModel:getChapterNum(num)
	local numStr = ""
	local len = 0

	if num == nil or tonumber(num) == 0 then
		return numStr,len
	else
		local modNum = num % 10 
		local divNum = math.floor(num / 10)

		if modNum == 0 then
			if divNum ~= 0 then
				if divNum == 1 then
					numStr = self.arabMap[0]
					len = 1
				else
					numStr = self.arabMap[divNum] .. self.arabMap[0]
					len = 2
				end
			end
		else
			if divNum ~= 0 then
				if divNum > 1 then
					numStr = self.arabMap[divNum] .. self.arabMap[0] .. self.arabMap[modNum]
					len = 3
				else
					numStr = self.arabMap[0] .. self.arabMap[modNum]
					len = 2
				end
			else
				numStr = self.arabMap[modNum]
				len = 1
			end
		end
	end

	return numStr,len
end

-- 获取上一章Id
-- 如果当前是第一章，返回当前章Id
function WorldModel:getLastStoryId(storyId)
	if self:isFirstChapter(storyId) then
		return storyId
	end

	local curStoryData = FuncChapter.getStoryDataByStoryId(storyId)
	local curChapterNum = curStoryData.chapter
	local curStageType = curStoryData.type

	local lastChapterNum = tonumber(curChapterNum) - 1

	local storyData = FuncChapter.getStoryData()
	for k,v in pairs(storyData) do
		if tonumber(v.type) == tonumber(curStageType) and tonumber(v.chapter) == tonumber(lastChapterNum) then
			return k
		end
	end

	return nil
end

-- 获取下一章Id
-- 如果当前是最后一章，返回当前章Id
function WorldModel:getNextStoryId(storyId)
	local curStoryData = FuncChapter.getStoryDataByStoryId(storyId)
	local curChapterNum = curStoryData.chapter
	local curStageType = curStoryData.type

	local maxStoryId = WorldModel:getMaxStoryId(curStageType)
	local maxStoryData = FuncChapter.getStoryDataByStoryId(maxStoryId)
	local maxChapterNum = maxStoryData.chapter

	if tonumber(curChapterNum) >= tonumber(maxChapterNum) then
		return storyId
	end

	local lastChapterNum = tonumber(curChapterNum) + 1

	local storyData = FuncChapter.getStoryData()
	for k,v in pairs(storyData) do
		if tonumber(v.type) == tonumber(curStageType) and tonumber(v.chapter) == tonumber(lastChapterNum) then
			return k
		end
	end

	return nil
end

-- 获取最大章id
function WorldModel:getMaxStoryId(stageType)
	local storyData = FuncChapter.getStoryData()

	local maxStoryId = nil
	for k,v in pairs(storyData) do
		if tonumber(v.type) == tonumber(stageType) then
			if maxStoryId == nil then
				maxStoryId = k
			end

			if tonumber(maxStoryId) < tonumber(k) then
				maxStoryId = k
			end
		end
	end

	return maxStoryId
end

-- 判断是否通关全章
function WorldModel:isPassStory(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)

	local stageType = storyData.type
	local raidId = nil
	if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
        raidId = UserExtModel:getMainStageId()
    elseif tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_ELITE then
        raidId = UserExtModel:getEliteStageId()
    end

    local maxRaidId = self:getStoryMaxRaidId(storyId)
    if tonumber(raidId) >= tonumber(maxRaidId) then
    	return true
    else
    	return false
    end
end

-- 获取已开启的章列表(至少通关一个关卡)
function WorldModel:getPassStoryList(stageType)
	local passMaxRaidId = nil
	if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
		passMaxRaidId = UserExtModel:getMainStageId()
	end

	local storyList = {}
	if passMaxRaidId == 0 then
		return storyList
	end

	local chapter = FuncChapter.getRaidAttrByKey(passMaxRaidId,"chapter")
	local firstStoryId = WorldModel:getFirstStoryId(stageType)

	local allStoryData = FuncChapter.getStoryData()

	
	for k,v in pairs(allStoryData) do
		if v.type == stageType and k >= firstStoryId and k <= tostring(chapter) then
			local firstRaidId = FuncChapter.getRaidIdByStoryId(k,1)
			if self:isPassRaid(firstRaidId) then
				storyList[#storyList+1] = k
			end
		end
	end

	table.sort(storyList,function(a,b)
		return a < b
	end)

	return storyList
end

-- 获取storyId，章内已通关raid列表
function WorldModel:getPassRaidList(storyId)
	local raidList = FuncChapter.getOrderRaidList(storyId)
	local passRaidList = {}
	for i=1,#raidList do
		local raidId = raidList[i]
		if self:isPassRaid(raidId) then
			passRaidList[#passRaidList+1] = raidId
		end
	end
	return passRaidList
end

function WorldModel:isOpenPVEMemory()
	local firstStoryId = self:getFirstStoryId(FuncChapter.stageType.TYPE_STAGE_MAIN)

	local firstRaidId = FuncChapter.getRaidIdByStoryId(firstStoryId,1)
	if self:isPassRaid(firstRaidId) then
		return true
	end

	return false
end

-- 获取章状态
function WorldModel:getStoryStatus(storyId)
	local curStatus = nil
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)

	local stageType = storyData.type

	local unlockMaxStoryId = self:getUnLockMaxStoryId(stageType)

	-- 未解锁
	if tonumber(storyId) > tonumber(unlockMaxStoryId) then
		curStatus = self.storyStatus.STATUS_LOCK
	elseif tonumber(storyId) == tonumber(unlockMaxStoryId) then
		curStatus = self.storyStatus.STATUS_UNLOCK
	elseif tonumber(storyId) < tonumber(unlockMaxStoryId) then
		curStatus = self.storyStatus.STATUS_PASS
	end
    
    return curStatus
end

-- 通过stageType,获取已经解锁的最大章id
function WorldModel:getUnLockMaxStoryId(stageType)
	local raidId = WorldModel:getNextUnLockRaidId(stageType)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)

	-- 本章已经是最后一章
	if raidData == nil then
		return nil
	end

	local unLockChapter = raidData.chapter

	return unLockChapter
end

-- 获取章中最大节数
function WorldModel:getStoryMaxSection(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	return storyData.section
end

-- 获取章中最大RaidId
function WorldModel:getStoryMaxRaidId(storyId)
	local maxSection = self:getStoryMaxSection(storyId)
	local raidData = FuncChapter.getRaidData()

	for k,v in pairs(raidData) do
		if tostring(v.chapter) == tostring(storyId) and tonumber(v.section) == tonumber(maxSection) then
			return k
		end
	end

	return nil
end

-- 获取章小场景分组数据列表
-- group与scene概念相同
function WorldModel:getStoryGroupList(storyId)
	local groupList = self.groupListCache[storyId]
	if groupList then
		return groupList
	end

	groupList = {}
	local allSceneData = FuncChapter.getSceneDataByStoryId(storyId)
	local orderList = FuncChapter.getSceneOrderList(storyId)
	local raidList = FuncChapter.getOrderRaidList(storyId)

	local beginIndex = 1

	for i=1,#orderList do
		local group = {}
		local groupIndex = i

		group.rids = {}
		group.index = groupIndex
		groupList[groupIndex] = group

		local curSceneOrder = orderList[i]
		local curSceneData = allSceneData[curSceneOrder]
		local raidNum = curSceneData.num
		local endIndex = beginIndex + raidNum - 1

		for i=beginIndex,endIndex do
			local raidId = raidList[i]
			table.insert(group.rids,raidId)
		end

		beginIndex = beginIndex + raidNum
	end

	-- 缓存数据
	self.groupListCache[storyId] = groupList
	return groupList
end

-- 获取关卡类型
function WorldModel:getRaidKind(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	return raidData.kind
end

-- 战斗前缓存
function WorldModel:setPVEBattleCache(cacheData)
	self.pveBattleCache = cacheData
	self:resetDataBeforeBattle()
end

-- 获取战斗缓存
function WorldModel:getPVEBattleCache()
	return self.pveBattleCache
end

-- 判断战斗是否胜利
function WorldModel:isPVEBattleWin()
	if self.pveBattleCache then
		local battleRt = self.pveBattleCache.battleRt
		return battleRt == Fight.result_win
	end

	return false
end

-- 设置是否进入PVE战斗
function WorldModel:setEnterPVEBattle(isEnter)
	self.isInPVEBattle = isEnter
end

function WorldModel:isBackFromPVEBattle(isEnter)
	return self.isInPVEBattle
end

-- 扫荡奖品累计
function WorldModel:countSweepRewards(rewardData)
	local totalReard = {}
	local totalSweepReward = {}

	local addReward = function(totalReard,curRewardStr)
		local rewardArr = string.split(curRewardStr,",")

		local find = false
		for i=1,#totalReard do
			local curRewardArr = totalReard[i]

			-- 找到相同的奖品
			if #rewardArr == 2 and rewardArr[1] == curRewardArr[1] then
				-- 数量相加
				curRewardArr[2] = curRewardArr[2] + rewardArr[2]
				find = true
			elseif #rewardArr == 3 and rewardArr[1] == curRewardArr[1] and rewardArr[2] == curRewardArr[2] then
				curRewardArr[3] = curRewardArr[3] + rewardArr[3]
				find = true
			end
		end

		if not find then
			-- 存储数组格式奖品
			totalReard[#totalReard+1] = rewardArr
		end
	end

	local addRewardArr = function(totalReard,rewardArr)
		for i=1,#rewardArr do
			local curRewardStr = rewardArr[i]
			addReward(totalReard,curRewardStr)
		end
	end

	for i=1,#rewardData do
		local rewardArr = rewardData[i].reward
		local sweepRewardArr = rewardData[i].sweepReward

		addRewardArr(totalReard,rewardArr)
		addRewardArr(totalSweepReward,sweepRewardArr)
	end

	self:convertRewardArrayToString(totalReard)
	self:convertRewardArrayToString(totalSweepReward)

	return totalReard,totalSweepReward
end

-- 奖品数组转字符串格式
function WorldModel:convertRewardArrayToString(rewardData)
	for i=1,#rewardData do
		local curRewardArr = rewardData[i]
		local rewardStr = ""
		for j=1,#curRewardArr do
			rewardStr = rewardStr .. curRewardArr[j]
			if j < #curRewardArr then
				rewardStr = rewardStr .. ","
			end
		end

		rewardData[i] = rewardStr
	end
end

-- 扫荡奖品排序表
-- 排序规则：限时掉落配置顺序，品质降序，道具id升序
function WorldModel:sortSweepRewards(rewardData)
	local sortReward = function(data)

		table.sort(data,function(a,b)
			local aRewardArr = string.split(a,",")
			local bRewardArr = string.split(b,",")
			
			local aItemId = aRewardArr[2]
			local bItemId = bRewardArr[2]

			local aLimitDropOrder = FuncDataSetting.getPVELimitDropOrder(aItemId)
			local bLimitDropOrder = FuncDataSetting.getPVELimitDropOrder(bItemId)

			local aQuality = FuncItem.getItemData(aItemId).quality
			local bQuality = FuncItem.getItemData(bItemId).quality

			if aLimitDropOrder < bLimitDropOrder then
				return true
			elseif aLimitDropOrder == bLimitDropOrder then
				if aQuality > bQuality then
					return true
				elseif aQuality == bQuality then
					if aItemId < bItemId then
						return true
					else
						return false
					end
				end
			end

	    end)
	end

	for i=1,#rewardData do
		local rewardArr = rewardData[i].reward
		local sweepRewardArr = rewardData[i].sweepReward
		if rewardArr then
			sortReward(rewardArr)
		end
		
		if sweepRewardArr then
			sortReward(sweepRewardArr)
		end
	end
end

-- 获取碎片需求数量
-- 如果没有合成，返回合成英雄需要的数量
-- 如果合成了，返回升星需要的数量
function WorldModel:getPartnerPiecesNeedNum(itemId)
	if PartnerModel:isHavedPatnner(itemId) then
		return PartnerModel:getUpStarNeedPartnerNum(itemId) or 0
	else
		return PartnerModel:getCombineNeedPartnerNum(itemId) or 0
	end
end

-- 查找下一个解锁提醒
function WorldModel:findNextGoalRaidId(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local storyId = raidData.chapter

	local goalRaidId = nil
	local raidArr = FuncChapter.getOrderRaidList(storyId)

	for i=1,#raidArr do
		local curRaidData = FuncChapter.getRaidDataByRaidId(raidArr[i])                                               
		if curRaidData.goal ~= nil and tostring(raidArr[i]) >= tostring(raidId) then
			goalRaidId = raidArr[i]
			return goalRaidId
		end
	end

	return goalRaidId
end

-- 精英副本是否开启
function WorldModel:isOpenElite()
	-- local firstRaidId = self:getFirstRaidId(FuncChapter.stageType.TYPE_STAGE_ELITE)
	-- local isOpenRaid = self:isOpenRaid(firstRaidId)
	local isopen, conditionValue, conditionType, lockTip =  FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ROMANCE)
	return isopen, lockTip
end

-- 主线副本是否开启
function WorldModel:isOpenMain()
	local firstRaidId = self:getFirstRaidId(FuncChapter.stageType.TYPE_STAGE_MAIN)
	return self:isOpenRaid(firstRaidId)
end

-- 共享副本是否开启
function WorldModel:isOpenShareBoss()
	-- local firstRaidId = self:getFirstRaidId(FuncChapter.stageType.TYPE_STAGE_ELITE)
	-- local isOpenRaid = self:isOpenRaid(firstRaidId)
	local isopen =  FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHAREBOSS)
	return isopen
end

-- 判断是否通关
function WorldModel:isPassRaid(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local passMaxRaidId = WorldModel:getMaxPassRaidId(raidData.type)
	return tostring(raidId) <= tostring(passMaxRaidId)
end

-- @deprecated
-- 判断是否通关全章
function WorldModel:isPassWholeStory(storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)

	local stageType = storyData.type
	local raidId = nil
	if tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_MAIN then
        raidId = UserExtModel:getMainStageId()
    elseif tonumber(stageType) == FuncChapter.stageType.TYPE_STAGE_ELITE then
        raidId = UserExtModel:getEliteStageId()
    end

    local maxRaidId = self:getStoryMaxRaidId(storyId)
    -- 通关并且领取了宝箱
    if tonumber(raidId) >= tonumber(maxRaidId) and self:hasUsedExtraBox(maxRaidId) then
    	return true
    else
    	return false
    end
end

-- @deprecated
-- 通关并且领取了
function WorldModel:isPassWholeRaid(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	if raidData then
		local passMaxRaidId = WorldModel:getMaxPassRaidId(raidData.type)
		if self:isEliteRaid(raidId) then
			return tostring(raidId) <= tostring(passMaxRaidId)
		else
			return tostring(raidId) <= tostring(passMaxRaidId) and self:hasUsedExtraBox(raidId)
		end
	else
		echoError("WorldModel:isPassWholeRaid raidData is nil and raidId=",raidId)
		return false
	end
end

-- 判断关卡是否开启
function WorldModel:isOpenRaid(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local conditionArr = raidData.condition

	-- 满足本关条件及上一关的条件
	local isOpen = false
	if not UserModel:checkCondition(conditionArr) then
		local lastRaidId = self:getLastRaidIdById(raidId)
		if lastRaidId then
			local lastCondition = FuncChapter.getRaidDataByRaidId(lastRaidId).condition
			if not UserModel:checkCondition(lastCondition) then
				isOpen = true
			end
		else
			isOpen = true
		end
	end
	return isOpen
end

-- 是否可以进入该关卡
-- 1.精英关卡：解锁会即可进入
-- 2.普通副本：在旧的回忆显示后才可进入
function WorldModel:canEnterRaid(raidId)
	--[[
	if self:isEliteRaid(raidId) then
		return self:isOpenRaid(raidId)
	else
		return self:isPassRaid(raidId)
	end
	]]
	
	return self:isOpenRaid(raidId)
end

-- 判断raidId和其前置关卡是否是同一章
function WorldModel:isSameChapter(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local conditionArr = raidData.condition

	local cond = conditionArr[1]
	local condRaidId = cond.v
	local condRaidData = FuncChapter.getRaidDataByRaidId(condRaidId)
	return raidData.chapter == condRaidData.chapter,condRaidId
end

-- 精英总次数
function WorldModel:getEliteRaidDayTimes()
    return FuncDataSetting.getDataByHid("RomanceExchangeNum").num
end

function WorldModel:isEliteRaid(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	return raidData.type == self.stageType.TYPE_STAGE_ELITE
end

-- 精英挑战最大购买次数
function WorldModel:getEliteMaxBuyTimes()
    local vipLevel = UserModel:vip();
    local maxBuyTimes = FuncCommon.getVipPropByKey(vipLevel, "interactTimes");
    return maxBuyTimes
end

-- 获得关卡剩余次数
function WorldModel:getEliteRaidLeftTimes(raidId)
    local dayTimes =  self:getEliteRaidDayTimes()
    local stageCounts = UserModel:stageCounts()
    local leftTimes = dayTimes

    if stageCounts then
        for k,v in pairs(stageCounts) do
            if tostring(v.id) == tostring(raidId) then
            	if TimeControler:getServerTime() > v.expireTime then
            		leftTimes = dayTimes - 0
            	else
            		leftTimes = dayTimes - v.count
            	end
                return leftTimes
            end
        end
    end

    return leftTimes
end

-- 获得关卡已购买次数
function WorldModel:getEliteBuyTimes(raidId)
    local stageCounts = UserModel:stageCounts()
    local buyTimes = 0

    if stageCounts then
        for k,v in pairs(stageCounts) do
            if tostring(v.id) == tostring(raidId) then
            	if TimeControler:getServerTime() > v.resetExpireTime then
            		buyTimes = 0
            	else
            		buyTimes = v.resetCount
            	end
                return buyTimes
            end
        end
    end

    return buyTimes
end

function WorldModel:getGetWayDes(raidId,desTid)
	local raidName = GameConfig.getLanguage(FuncChapter.getRaidAttrByKey(raidId,"name"))
	local storyId = FuncChapter.getRaidAttrByKey(raidId,"chapter")
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local chapter = storyData.chapter

	local getWayDes = GameConfig.getLanguageWithSwap(desTid,chapter,raidName)
	return getWayDes
end

-- 是否开启掉落活动
function WorldModel:isOpenDropActivity()
	local actTaskIdList = FuncActivity.getActivityTaskListByCondition(self.activity.ACTIVITY_DROP_TIMES)
	local actId = nil

	for i=1,#actTaskIdList do
		local actTaskId = actTaskIdList[i]
		if FuncActivity.isActivityTaskOnline(actTaskId) then
			actId = actTaskId

			return true,actId
		end
	end

	return false
end

-- 获取掉落倍数
function WorldModel:getDropTimes()
	local dropTimes = 1
	local open,actTaskId = self:isOpenDropActivity()
	if open and actTaskId then
		local activityConfig = FuncActivity.getActivityTaskConfig(actTaskId)
		dropTimes = activityConfig.conditionNum
	end

	return dropTimes
end

-- new world
-- 是否可以进入地标
function WorldModel:canEnterSpace(spaceName)
	local spaceData = FuncChapter.getSpaceDataByName(spaceName)
	local conditon = spaceData.condition

	return not UserModel:checkCondition(conditon)
end

-- 获取关卡名称
function WorldModel:getRaidName(raidId)
	return GameConfig.getLanguage(FuncChapter.getRaidAttrByKey(raidId,"name"))
end

-- 获取章名称
function WorldModel:getStoryName(storyId)
	local storyId = tostring(storyId)
	if raidId == "nil" then
		return nil
	end

	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local name = nil
	if storyData ~= nil then
		name = storyData.name
		-- dump(storyData,"章数据 = ")
		-- echo("名字为 = ",GameConfig.getLanguage(name))
	end

	return GameConfig.getLanguage(name)
end

-- 根据关卡id获得所在章的名字
function WorldModel:getStoryNameByRaidId(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local storyId = raidData.chapter
	return self:getStoryName(storyId)
end



-- 获取关卡第几回描述
function WorldModel:getRaidRoundDes(raidId)
	--echoError("当前的raidId",raidId,"====================")
	local section = FuncChapter.getRaidAttrByKey(raidId,"section")
	local capNum = WorldModel:getChapterNum(section)
	-- local raidDes = "第" .. capNum .. "回"
	local raidDes = GameConfig.getLanguageWithSwap("tid_story_10018",capNum)
	echo(raidDes,"============")
	return raidDes
end

-- 传入关卡raidId，返回第几章(int)
function WorldModel:getStoryRoundDes(raidId)
	-- echoError("当前的raidId",raidId,"====================")

	local raidData = FuncChapter.getRaidDataByRaidId(tostring(raidId))
	if raidData == nil then
		return nil
	end

	local storyId = raidData.chapter
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local chapter = nil
	if storyData ~= nil then
		chapter = storyData.chapter
	end
	-- echo("chapter == ",chapter)
	return chapter
end





function WorldModel:getSpaceLevelLimit(spaceName)
	local spaceData = FuncChapter.getSpaceDataByName(spaceName)
	local condArr = spaceData.condition
	local levelLimit = self:getConditionLevel(condArr)
	return levelLimit
end

function WorldModel:getRaidLevelLimit(raidId)
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local condArr = raidData.condition
	local levelLimit = self:getConditionLevel(condArr)
	return levelLimit
end

function WorldModel:getConditionLevel(condArr)
	local levelLimit = 0
	for i=1,#condArr do
		if condArr[i].t == UserModel.CONDITION_TYPE.LEVEL then
			levelLimit = condArr[i].v
			return levelLimit
		end
	end
	return levelLimit
end

function WorldModel:getFakePlayerList(num)
	local topestRobotConfig = PVPModel:getTopestRobotByParam(num);
    local manualPlayerData = {};

    for k, v in pairs(topestRobotConfig) do
        local rid = FuncPvp.genRobotRid(v.id);
        local name = FuncAccountUtil.getRobotName(rid);
        local level = v.lv;
        local avatar = v.avatar;
        local status = 1;
        local state = 1;
        local ability = v.ability;
        local garmentId = v.garmentId
        
        local playerInfo = {
            ["_id"] = rid,
            ["rid"] = rid,
            ["avatar"] = avatar,
            ["level"] = level,
            ["name"] = name,
            ["status"] = status,
            ["state"] = state,
            ["isRobot"] = true,
            ["ability"] = ability,
            ["garmentId"] = garmentId
        }
        
        manualPlayerData[tostring(rid)] = playerInfo;
    end

    return manualPlayerData
end

function WorldModel:repairFakePlayerInfo(playerInfo)
	local rid = playerInfo.rid
	local _robot_item = FuncPvp.getRobotById(rid)

    --所携带的法宝,以及和法宝相关的槽位
    local _treasureInfos = {
    }
    local _treasureFormation = {}
    for _key,_value in pairs( _robot_item.treasures) do
        _treasureInfos[tostring(_value.id)] = _value
        if table.length(_treasureFormation) < 2 then
            _treasureFormation["p"..(table.length(_treasureFormation)+1)] = tostring(_value.id)
        end
    end
    --伙伴以及伙伴的阵型
    local _partners = {
    }
    local _partnerFormation={}
    for _index=1,6 do
        local _partnerInfo = _robot_item["showPart".._index]
        if _partnerInfo ~=nil then
            _partners[_partnerInfo[1] ] ={
                id = tonumber(_partnerInfo[1]),
                level = tonumber(_partnerInfo[2]),
                star = tonumber(_partnerInfo[3]),
                quality = tonumber(_partnerInfo[4]),
            }
            _partnerFormation["p".._index] = _partnerInfo[1]
        end
    end
    --有关伙伴,法宝的槽位
    local _formations ={
        partnerFormation = _partnerFormation,
        treasureFormation = _treasureFormation,
    }

    playerInfo.treasures = _treasureInfos
    playerInfo.partners = _partners
    playerInfo.formations = _formations

    -- --数据的整合
    -- local _playerInfo = {
    --     rid = playerInfo.rid,
    --     level = _robot_item.lv,
    --     avatar = self.info.avatar,
    --     types = 1,
    --     treasures = _treasureInfos,
    --     partners = _partners,
    --     formations = _formations,
    -- }
end

-- 检查扫荡10次条件
function WorldModel:checkSweepTenOpen()
	local isOpen = false
	local tipMsg = nil

	-- 等级条件
	local condMap = FuncDataSetting.getDataVector("PVESweepTenLevelLimit")
	local newCondArr = {}
	if condMap then
		for k,v in pairs(condMap) do
			local cond = {}
			cond.t = tonumber(k)
			cond.v = v
			newCondArr[#newCondArr+1] = cond
		end

		local condType = UserModel:checkCondition(newCondArr)
		if not condType then
			isOpen = true
		else
			tipMsg = UserModel:getConditionTip(newCondArr)
		end
	end

	return isOpen,tipMsg
end

-- 检查扫荡1次是否开启
function WorldModel:checkSweepOneOpen()
	local isOpen = false
	local tipMsg = nil

	local condMap = FuncDataSetting.getDataVector("PVESweepOneLevelLimit")
	local newCondArr = {}
	if condMap then
		for k,v in pairs(condMap) do
			local cond = {}
			cond.t = tonumber(k)
			cond.v = v
			newCondArr[#newCondArr+1] = cond
		end

		local condType = UserModel:checkCondition(newCondArr)
		if not condType then
			isOpen = true
		else
			tipMsg = UserModel:getConditionTip(newCondArr)
		end
	end
	-- echo("_检查扫荡一次的条件 _______ isOpen,tipMsg ________ ",isOpen,tipMsg)
	return isOpen,tipMsg
end


-- 根据给定的两个关卡id返回他们之间的关卡数
--DateTime:    2017-09-22 18:37:35 zgy
-- 若传入的第一个参数为0 则表示还未开始序章
-- 注意此时的处理
function WorldModel:getBetweenRaidNum(_raidId1, _raidId2)
	echo("________ _raidId1, _raidId2 _____________",_raidId1, _raidId2)
	local raidId1 = _raidId1
	local raidId2 = _raidId2
	local haveNotInit = false
	local betweenRaidNum = 0
	if not raidId1 or tostring(raidId1) == "0" then
		raidId1 = "10001"
		haveNotInit = true
	end
	-- if storyId2 and tonumber(raidId2) > 111110 then
		-- 限制最高关卡
	-- end
	echo("________ _raidId1, _raidId2 _____________",raidId1, raidId2)

	local storyId1 = FuncChapter.getStoryIdByRaidId(raidId1)
	local storyId2 = FuncChapter.getStoryIdByRaidId(raidId2)
	local chapter1 = FuncChapter.getChapterByStoryId(storyId1)
	local chapter2 = FuncChapter.getChapterByStoryId(storyId2)

	local section1 = FuncChapter.getSectionByRaidId(raidId1)
	local section2 = FuncChapter.getSectionByRaidId(raidId2)
	if storyId1 == storyId2 then
		if haveNotInit then
			betweenRaidNum = section2 - section1 + 1 
		else
			betweenRaidNum =  section2 - section1
		end
	else
		local num1 = FuncChapter.getMaxSectionByStoryId(storyId1)
		num1 = num1 - section1

		local num2 = 0
		local betweenStoryNum = chapter2 - chapter1 - 1
		if betweenStoryNum ~= 0 then
			local begin = chapter1 + 1
			local endc = chapter1 + betweenStoryNum
			local storyData1 = FuncChapter.getStoryDataByStoryId(storyId1)
			for i = begin,endc do
				storyData = FuncChapter.getStoryDataByChapter(i,storyData1.type)
				num2 = FuncChapter.getMaxSectionByStoryId(storyData.id) + num2 
			end
		end

		local num3 = section2
		-- echo("--- 大大大大大大大大  num1 ,num2 , num3----",num1 ,num2 , num3)
		if haveNotInit then
			betweenRaidNum = num1 + num2 + num3 + 1 
		else
			betweenRaidNum =  num1 + num2 + num3
		end
	end
	echo("--- betweenRaidNum  ----",betweenRaidNum)
	print("\n\n\n\n ")

	return betweenRaidNum
end

-- 判断主角是否被限定位置(被限定后主角在六界地图中必须出现创建在npc的附近,而不是上次的位置)
function WorldModel:checkCharInPositionLimit()
	local limitLevel = FuncDataSetting.getDataByConstantName("WorldLevelPosition")
	local level = UserModel:level()
	if limitLevel and tonumber(level) <= tonumber(limitLevel)  then
		return true
	end

	return false
end

--[[
	判断主角是否被限定在指定位置(比如：某关卡，主角必须出现在指定位置)
]]
function WorldModel:checkCharInTargetPositionLimit(raidId)
	if raidId == nil or raid == "" then
		return false
	end

	local charTargetPosCfg = self:getCharTargetPositionCfg()
	if charTargetPosCfg and charTargetPosCfg[tostring(raidId)] then
		return true
	end

	return false
end

--[[
	获取主角指定关卡的指定位置
]]
function WorldModel:getCharTargetPosition(raidId)
	local charTargetPosCfg = self:getCharTargetPositionCfg()
	dump(charTargetPosCfg,"charTargetPosCfg------------")
	if charTargetPosCfg and charTargetPosCfg[tostring(raidId)] then
		return charTargetPosCfg[tostring(raidId)]
	end

	return nil
end

--[[
	获取主角指定位置的配置数据
]]
function WorldModel:getCharTargetPositionCfg()
	local charTargetPosCfg = self.charTargetPosCfg
	if charTargetPosCfg == nil then
		charTargetPosCfg = {}
		local cfg = FuncDataSetting.getDataArrayByConstantName("PlayerPositionAfterWar")
		if cfg then
			for k,v in pairs(cfg) do
				local arr = string.split(v,",")
				charTargetPosCfg[arr[1]] = cc.p(tonumber(arr[2]),tonumber(arr[3]))
			end
		end 

		self.charTargetPosCfg = charTargetPosCfg
	end

	return self.charTargetPosCfg
end

--[[
	检查该关卡npc是否显示手指动画
]]
function WorldModel:checkShowHandAnim(raidId)
	if not raidId then
		return false
	end

	local raidList = FuncDataSetting.getDataByHid("WorldNpcHandRaidList")
	if not raidList or not raidList.arr then
		return false
	end

	local arr = raidList.arr
	for i=1,#arr do
		if tostring(raidId) == arr[i] then
			return true
		end
	end

	return false
end

return WorldModel

