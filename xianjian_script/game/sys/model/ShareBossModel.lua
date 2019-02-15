--
-- Author: LXH
-- Date: 2017-10-13
--

local ShareBossModel = class("ShareBossModel", BaseModel)

function ShareBossModel:ctor()

end

ShareBossModel.eventName = "ShareBoss_Event_"

function ShareBossModel:init(d)
	ShareBossModel.super:init(self, d)

	self.maxCountEveryDay = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryDay")
    self.maxShareBossRescue = FuncDataSetting.getDataByConstantName("MaxShareBossRescue")

	self.shareBossList = {}
	self.sortedBossList = {}
	self._allEvent = {}

	self:registerEvent()
	-- self:createKeyFunc()
	self:isShowHomeViewTips()
end

function ShareBossModel:updateData(_data)
	ShareBossModel.super.updateData(self, _data)

	if _data and _data.shareBossList then
		self.shareBossList = _data.shareBossList
		self:chkStorageAuto()
	end	
end


function ShareBossModel:registerEvent()
 	EventControler:addEventListener("notify_shareBoss_data_changed_5408", self.updateShareBossData, self)
end

--检查是否需要 向主城推送幻境协战的入口
function ShareBossModel:isShowHomeViewTips()
	if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHAREBOSS) then
		return
	end
	
	if CountModel:getShareBossChallengeCount() >= self.maxCountEveryDay then
		return
	end

	ShareBossServer:getShareBossList(function (event)
			if event.error then
		        echo("没有拉取到共享副本的数据")
		    else
		        self:pushShareBossLogic(event.result.data)
		    end
		end)
end

function ShareBossModel:checkHaveCountByData(_data)
	if _data.challengeCounts and table.length(_data.challengeCounts) > 0 then
		for k,v in pairs(_data.challengeCounts) do
			if tostring(k) == tostring(UserModel:rid()) then
				return false
			end
		end
	end
	return true
end

--推送是否显示主城入口逻辑
function ShareBossModel:pushShareBossLogic(data)
	local canShowList = {}
	if data.shareBossList and table.length(data.shareBossList) > 0 then
		for k,v in pairs(data.shareBossList) do
			if k == UserModel:rid() then
				canShowList[k] = v
			else
				if v.open and v.open == 1 then
					canShowList[k] = v
				end
			end
		end
	end

	if table.length(canShowList) > 0 then
		if not self.lastCacheData then
			self.lastCacheData = canShowList
			self.shareBossStar = self:getMaxStar(self.lastCacheData)
			EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI, {})
		else
			local maxStar = 0
			for k,v in pairs(canShowList) do
				local star = FuncShareBoss.getBossStarById(v.bossId)
				if maxStar < tonumber(star) and self:checkHaveCountByData(v) then
					maxStar = tonumber(star)
				end
			end
			
			if self.shareBossStar and self.shareBossStar ~= maxStar then
				self.lastCacheData = canShowList
				self.shareBossStar = maxStar
				EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI, {})
			end
		end
	else
		if self.lastCacheData then
			self.lastCacheData = nil
			self.shareBossStar = 0
			EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI, {})
		end
	end
end

function ShareBossModel:getMaxStar(data)
	local maxStar = 0
	for k,v in pairs(data) do
		local star = FuncShareBoss.getBossStarById(v.bossId)
		if maxStar < tonumber(star) then
			maxStar = tonumber(star)
		end
	end

	return maxStar
end

--获取是否需要显示主城入口的变量
function ShareBossModel:needShowShareBossForHomeView()
	if CountModel:getShareBossChallengeCount() >= self.maxCountEveryDay then
		return 0
	end
	return self.shareBossStar or 0
end

function ShareBossModel:updateShareBossData(event)
	local data = event.params
	dump(data,"shareBoss血量同步 ======推送")
	local bossId = data.params.data._id
	local currentTime = TimeControler:getServerTime()
	-- 如果已经过期了 从数据中删除
	if currentTime >= data.params.data.expireTime then
		self.shareBossList[tostring(bossId)] = nil
	else
		local totalHp, curDamage = ShareBossModel:updateHpStatus(data.params.data)
		--如果boss已经死亡从数据中删除
		if curDamage < totalHp then
			self.shareBossList[tostring(bossId)] = data.params.data
		else
			data.params.data.isDead = true
			self:saveLocalDeadShareBossData(data.params.data)

			self.shareBossList[tostring(bossId)] = nil	
		end		
	end	
	EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_DATA_CHANGED, {_id = bossId})
	self:isShowHomeViewTips()
end

--保存已死亡boss数据到本地
function ShareBossModel:saveLocalDeadShareBossData(_data)
	local deadShareBoss = LS:prv():get(StorageCode.dead_shareBoss, "")

	if deadShareBoss == nil or deadShareBoss == "" then
		deadShareBoss = {}
		deadShareBoss[tostring(_data._id)] = _data
	else
		deadShareBoss = json.decode(deadShareBoss)

		if deadShareBoss[tostring(_data._id)] then
			deadShareBoss[tostring(_data._id)] = _data
		else
			if table.length(deadShareBoss) < 5 then
				deadShareBoss[tostring(_data._id)] = _data
			else
				deadShareBoss[self:getFirstExpireBoss(deadShareBoss)] = nil
				deadShareBoss[tostring(_data._id)] = _data
			end
		end
	end

	LS:prv():set(StorageCode.dead_shareBoss, json.encode(deadShareBoss))
end

--获取最先过期的数据
function ShareBossModel:getFirstExpireBoss(shareBossData)
	local bossId = nil
	local time = 0
	for k,v in pairs(shareBossData) do
		if not bossId then
			bossId = k
			time = v.expireTime
		elseif time > v.expireTime then
			bossId = k
			time = v.expireTime
		end 
	end

	return bossId
end

function ShareBossModel:setOpendShareBossData(open, expireTime)
	self.shareBossList[tostring(UserModel:rid())].open = open
	self.shareBossList[tostring(UserModel:rid())].expireTime = expireTime
	EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_DATA_CHANGED)
end

--计算血量状态  获取总血量和当前伤害量
function ShareBossModel:updateHpStatus(_bossData)
	local totalHp = 0
	local currentHp = 0
	local enemyHp = 0
	local levelId = FuncShareBoss.getLevelIdById(tostring(_bossData.bossId))
	local enemyIds = FuncShareBoss.getEnemyIdByLevelId(levelId)
	for i, v in ipairs(enemyIds) do
		if v ~= "" then
			enemyHp = FuncShareBoss.getBossHpById(v, _bossData.bossId)
			totalHp = totalHp + tonumber(enemyHp)
		end
	end

	local damage = 0
	if _bossData.bossHp == nil or _bossData.bossHp == {} then
		currentHp = totalHp
	else
		for k,v in pairs(_bossData.bossHp) do
			local id_table = string.split(k, "_")
			local upperHp = FuncShareBoss.getBossHpById(id_table[1], _bossData.bossId)
			if  tonumber(upperHp) < tonumber(v) then
				v = upperHp
			end
			damage = damage + tonumber(v)
		end
	end
	return totalHp, damage
end

--删除过期的boss数据 然后更新界面
function ShareBossModel:deleteExpireShareBossData(_bossId)
	self.shareBossList[tostring(_bossId)] = nil
	EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_DATA_CHANGED, {_id = _bossId})
end

function ShareBossModel:setAllBossDatas()
	local function callBack(_param)
		if _param.result then
			self.shareBossList = _param.result.data.shareBossList

			-- dump(_param.result.data.shareBossList, "\n\n_param.result.data.shareBossList")
			EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_DATA_CHANGED)
			self:chkStorageAuto()
    	elseif _param.error then
    		echo("返回数据报错")
    	end

	end
	ShareBossServer:getShareBossList(callBack)
end

function ShareBossModel:mergeLocalData()
	local deadShareBoss = LS:prv():get(StorageCode.dead_shareBoss, "")
	if deadShareBoss == nil or deadShareBoss == "" then
		deadShareBoss = {}
	else
		deadShareBoss = json.decode(deadShareBoss)
	end

	local deadShareBoss_copy = table.deepCopy(deadShareBoss)
	for k,v in pairs(deadShareBoss_copy) do
		if k == UserModel:rid() then
			v.weight = 2	
		else
			v.weight = 0
		end

		if not self.shareBossList[v._id] then
			table.insert(self.sortedBossList, v)
		else
			deadShareBoss[k] = nil
		end
	end
	
	LS:prv():set(StorageCode.dead_shareBoss, json.encode(deadShareBoss))
end

function ShareBossModel:chkStorageAuto( )
	-- 这个地方对boss的自动战斗存储数据做一个遍历，然后删除掉对应的自动战斗标签
    local sbStr = LS:prv():get(StorageCode.battle_shareboss_auto,nil)
    if sbStr then
        local tmpArr = json.decode(sbStr)
        if type(tmpArr) ~= 'table' then
	    	tmpArr = {}
        end
        for k,v in pairs(tmpArr) do
        	local isHave = false
        	for m,n in pairs(self.shareBossList) do
        		if k == m then
        			isHave = true
        			break
        		end
        	end
        	if not isHave then
        		-- 说明已经不存在这个boss、则吧对应的自动战斗标签设置为0
        		tmpArr[k] = 0
        	end
        end
        LS:prv():set(StorageCode.battle_shareboss_auto,json.encode(tmpArr))
    end
end

function ShareBossModel:getAllBossDatas()
	self:sortAllBossDatas()
	return self.sortedBossList
end

function ShareBossModel:checkIsInTable(_key, _table)
	if _key == nil or tostring(_key) == "" then
		return false
	end
	if _table and table.length(_table) > 0 then
		for k,v in pairs(_table) do
			if tostring(_key) == tostring(k) then
				return true
			end
		end
	end
	return false
end


function ShareBossModel:sortAllBossDatas()
	self.sortedBossList = {}
	self:mergeLocalData()

	if self.shareBossList and table.length(self.shareBossList) > 0 then
		for k, v in pairs(self.shareBossList) do
			if k == UserModel:rid() then
				v.weight = 2
				table.insert(self.sortedBossList, v)
			-- elseif v.challengeCounts then
			-- 	if self:checkIsInTable(UserModel:rid(), v.challengeCounts) then
			-- 		v.weight = 1
			-- 	else
			-- 		v.weight = 0
			-- 	end		
			else
				v.weight = 0
				if v.open and v.open == 1 then
					table.insert(self.sortedBossList, v)
				end
			end
		end	
	end

	local function sortFunc(a, b)
		if a.weight > b.weight then
			return true
		elseif a.weight == b.weight then
			return a.expireTime < b.expireTime
		else
			return false
		end
	end
	
	table.sort(self.sortedBossList, sortFunc)
end

function ShareBossModel:getBossDataById(_id)
	return self.shareBossList[_id]
end

function ShareBossModel:getLeftTimeById(_id)
	local bossData = self.shareBossList[_id]
	return bossData.expireTime
end

function ShareBossModel:setFindRewardStatus(_findReward)
	if _findReward and table.length(_findReward) > 0 then
		self.findReward = _findReward
	end
end

function ShareBossModel:resetFindReward()
	self.findReward = {}
end

function ShareBossModel:getFindReward()
	return self.findReward
end

function ShareBossModel:checkFindReward()
	local findReward = self:getFindReward()
	if findReward ~= nil and table.length(findReward) > 0 then
		return true
	end
	return false
end
function ShareBossModel:setFindRewardFlag(_flag)
	self.findRewardFlag = _flag
end

function ShareBossModel:resetFindRewardFlag()
	self.findRewardFlag = false
end

function ShareBossModel:checkRedPoint()
	-- local maxCount = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryDay")
	-- if self._data.shareBossList and table.length(self._data.shareBossList) > 0 then
	-- 	if CountModel:getShareBossChallengeCount() < maxCount then
	-- 		return true
	-- 	end
	-- end
	return false
end

function ShareBossModel:setSelectedId(_id)
	if _id then
		self.selectedId = _id
	end	
end

function ShareBossModel:getSelectedId()
	return self.selectedId
end

function ShareBossModel:isOpen()
	local isOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHAREBOSS)
	return isOpen
end

function ShareBossModel:hasInBattle()
	local sortedList = self:getAllBossDatas()
	local battleList = {}
	for i,v in ipairs(sortedList) do
		if v.challengeCounts then
			if self:checkIsInTable(UserModel:rid(), v.challengeCounts) then
				table.insert(battleList, v._id)
			end
		end
	end
	return battleList
end

function ShareBossModel:setCurMaxIndex(index)
	self.curMaxIndex = index
end

function ShareBossModel:getCurMaxIndex()
	return self.curMaxIndex or 1
end

--设置当前所在的group
function ShareBossModel:setCurrentGroup(index)
	self.currentGroup = index
end

--获取当前所在的group
function ShareBossModel:getCurrentGroup()
	return self.currentGroup
end

function ShareBossModel:setNeedFindMaxStar(_needMaxStar)
	self._needMaxStar = _needMaxStar
end

function ShareBossModel:getNeedFindMaxStar()
	return self._needMaxStar
end

function ShareBossModel:setCurrentDetailData(_data)
	self.currentDetailData = _data
end

function ShareBossModel:getCurrentDetailData()
	return self.currentDetailData
end

return ShareBossModel