--[[
	Author: lxh
	Date:2017-10-13
	Description: 共享副本主界面
]]

local ShareBossMainView = class("ShareBossMainView", UIBase);

function ShareBossMainView:ctor(winName)
    ShareBossMainView.super.ctor(self, winName)
end

function ShareBossMainView:loadUIComplete()
	self:initData()	
	self:registerEvent()	
	self:initViewAlign()
	self:initView()		 
end 


function ShareBossMainView:registerEvent()
	ShareBossMainView.super.registerEvent(self);

	self.tagPanel = self.panel_yeqian
	self.btn_back:setTouchedFunc(c_func(self.close, self))
	self.tagPanel.mc_yeqian1:setTouchedFunc(c_func(self.touchedYeQian, self, self.selectTagType.TAG_XIANG_QING))
	self.tagPanel.mc_yeqian2:setTouchedFunc(c_func(self.touchedYeQian, self, self.selectTagType.TAG_PAI_HANG))
	EventControler:addEventListener(ShareBossEvent.SHAREBOSS_DATA_CHANGED, self.updateViewData, self)
	EventControler:addEventListener(ShareBossEvent.SHAREBOSS_NUM_CHANGED, self.updateNumChangedData, self)
	EventControler:addEventListener(ShareBossEvent.SHAREBOSS_RANK_DATA_CHANGED, self.updateRankData, self)
	EventControler:addEventListener(ShareBossEvent.SHAREBOSS_CHALLENGE_RESET, self.updateViewData, self)
	EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.enterBattle, self)
	EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP, self.stopEvent, self)
	self.btn_wen:setTouchedFunc(c_func(self.touchedRuleBtn, self))
end

function ShareBossMainView:touchedRuleBtn()
	WindowControler:showWindow("ShareBossHelpView")
end

function ShareBossMainView:updateNumChangedData()
	ShareBossModel:setAllBossDatas()
end

function ShareBossMainView:updateRankData()	
	local _bossData = ShareBossModel:getBossDataById(self.selectedId)
	self.rankDatas = _bossData.totalDamages
	local bool = self:checkHaveRank(_bossData)
	if self.curTagType and self.touchYeQian == true then
		-- echo("\n\nself.curTagType===", self.curTagType)
		self.curTagType = self.curTagType
	else
		if bool == true then
			-- echo("\n\n————————————排行————————————")
			self.curTagType = self.selectTagType.TAG_PAI_HANG
		else
			-- echo("\n\n————————————详情————————————")
			self.curTagType = self.selectTagType.TAG_XIANG_QING
		end
	end
	
	self.leftTime = _bossData.expireTime
	-- self:updateSelectedStatusInScroll(_id)
	self:updateSpineView(self.selectedId)
	self:updateDetailView(self.selectedId, self.curTagType)
	self:updateSelectedStatusInScroll(self.selectedId)
end

function ShareBossMainView:updateViewData()
	echo("\n\n_________updateViewData_________")
	self.bossDatas = {}
	local bossDatas = ShareBossModel:getAllBossDatas()
	-- dump(bossDatas, "\n\nbossDatas")
	for i,v in ipairs(bossDatas) do
		if v.expireTime > TimeControler:getServerTime() then
			table.insert(self.bossDatas, v)
		end
	end
	
	self:updateMainUI(self.bossDatas, self.curTagType)
end
function ShareBossMainView:initData()
	self.bossDatas = ShareBossModel:getAllBossDatas()
	self.selectTagType = {
        TAG_XIANG_QING = 1,      
        TAG_PAI_HANG = 2,       
    }

    self.isStop = false
    self.touchYeQian = false
    self.indexDataMap = {}
    self.frameCount = 0
    self.panel = self.mc_xx:getViewByFrame(1)
    self.maxCountEveryBoss = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryBoss")
    self.maxCountForSameTime = FuncDataSetting.getDataByConstantName("MaxShareBossBesides")
    self.maxCountEveryDay = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryDay")
    self.maxShareBossRescue = FuncDataSetting.getDataByConstantName("MaxShareBossRescue")
	self.bottomScrollList = self.panel.panel_latiao.scroll_1
	self.rankPanel = self.panel.panel_xinxi.mc_nr:getViewByFrame(2)
	self.notGetReward = false
	local currentCount = CountModel:getShareBossChallengeCount()
	self.leftCountString = ""
	if currentCount < self.maxCountEveryDay then
		self.leftCountString = GameConfig.getLanguageWithSwap("#tid_shareboss_401" , self.maxCountEveryDay - currentCount)
	elseif currentCount >= self.maxCountEveryDay then
		local rescueCount = currentCount - self.maxCountEveryDay
		
		if rescueCount < self.maxShareBossRescue then
			self.leftCountString = GameConfig.getLanguage("#tid_shareboss_402")
		else
			self.notGetReward = true
			self.leftCountString = GameConfig.getLanguage("#tid_shareboss_403")
		end
		
	end
end

function ShareBossMainView:onBecomeTopView()
	self.isStop = false
end

function ShareBossMainView:stopEvent()
	if WindowControler:checkCurrentViewName("ShareBossMainView") == true then
		return 
	end
	self.isStop = true
end

function ShareBossMainView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_ShareBoss_002"))
	self.UI_1.btn_1:setVisible(false)
	self:updateMainUI(self.bossDatas)
end

function ShareBossMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_name, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_wen, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_res, UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.rich_x1, UIAlignTypes.Middle)
end

function ShareBossMainView:clickBattle()
	local _bossData = ShareBossModel:getBossDataById(self.selectedId)
	local trid = _bossData._id
	local tsec = _bossData.sec
	local tags = FuncCommon.splitStringIntoTable(_bossData.tagsStr)
	-- local battleList = ShareBossModel:hasInBattle()
	-- if #battleList == 2 and table.indexof(battleList, trid) == false then
		-- echoError("\n\n__________最多只能同时挑战2个副本____________")
	-- 	WindowControler:showTips(FuncTranslate._getErrorLanguage("#error540301"))
	-- else
	local canzhanCount = 0
	if _bossData.challengeCounts and table.length(_bossData.challengeCounts) > 0 then
		for k,v in pairs(_bossData.challengeCounts) do
			if k == UserModel:rid() then
				canzhanCount = v
				break
			end
		end		
	end
	local attr = FuncShareBoss.getBuffAttrByBuffId(tostring(_bossData.buffId))
	local levelId = FuncShareBoss.getLevelIdById(_bossData.bossId)
	-- echo("\n\ncanzhanCount=", canzhanCount, "self.maxCountEveryBoss=", self.maxCountEveryBoss)
	if canzhanCount < self.maxCountEveryBoss then
		local params = {}
	    params[FuncTeamFormation.formation.shareBoss] = {
	        raidId = levelId,
	        trid = trid,
	        tsec = tsec,
	        tags = tags,
	        tagsDescription = self.buffDes,
	        attr_addition = attr,
	    }

	    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.shareBoss,params)
		-- ShareBossServer:challengeShareBossList(formation, trid, tsec, c_func(self.doFormationCallBack, self))
	else
		-- echoError("\n\n__________该副本挑战次数已达到上限____________")
		WindowControler:showTips(FuncTranslate._getErrorLanguage("#error540303"))
	end
	-- end	
end

function ShareBossMainView:enterBattle(params)
	local params = params.params
	local formation = params.formation
	local trid = params.params[FuncTeamFormation.formation.shareBoss].trid
	local tsec = params.params[FuncTeamFormation.formation.shareBoss].tsec
	ShareBossModel:setSelectedId(trid)
	if params.systemId == FuncTeamFormation.formation.shareBoss then
		ShareBossServer:challengeShareBossList(formation, trid, tsec, c_func(self.doFormationCallBack, self))
	end
end

function ShareBossMainView:doFormationCallBack(event)
    if event.result then
      	 -- echo("----进战斗数据----")
        if event.result.data then
	        -- ShareBossModel:setShareBossBattleInfo(event.result.data)
        	local serviceData = event.result.data.battleInfo
        	-- dump(serviceData,"serviceData=====")
        	serviceData.battleLabel = GameVars.battleLabels.shareBossPve

	        local battleInfoData = BattleControler:turnServerDataToBattleInfo(serviceData)
	        -- dump(battleInfoData,"zhandou=====")
	        EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
	        BattleControler:startBattleInfo(battleInfoData)

        end       
    end
end

function ShareBossMainView:updateMainUI(_data, _curTagType)
	if table.length(_data) > 0 then
		self.mc_xx:showFrame(1)
		local selectedId = ShareBossModel:getSelectedId()
		if selectedId and self:checkBossIsInList(selectedId, self.bossDatas) then
			self.selectedId = selectedId
		else
			self.selectedId = self.bossDatas[1]._id
		end
		local _bossData = ShareBossModel:getBossDataById(self.selectedId)
		if _curTagType then
			self.curTagType = _curTagType
		else
			local bool = self:checkHaveRank(_bossData)
			if bool == true then
				self.curTagType = self.selectTagType.TAG_PAI_HANG
			else
				self.curTagType = self.selectTagType.TAG_XIANG_QING
			end
		end

		self.leftTime = _bossData.expireTime
		self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self), 0)
		self.panel.panel_xinxi.mc_1:setTouchedFunc(c_func(self.clickBattle, self))
		self:updateUI(self.curTagType)
		self:initScrollCfg()
		self.rich_x1:setString(self.leftCountString)
		-- local trid = _bossData._id
		-- local tsec = _bossData.sec
		-- ShareBossModel:setShareBossRankData(trid, tsec)
	else
		self.mc_xx:showFrame(2)
		self.panel_yeqian:setVisible(false)
		self.rich_x1:setString("")
	end
end

function ShareBossMainView:checkHaveRank(_data)
	if _data.challengeCounts and table.length(_data.challengeCounts) > 0 then
		for k,v in pairs(_data.challengeCounts) do
			if tostring(k) == tostring(UserModel:rid()) then
				return true
			end
		end
	end
	return false
end

function ShareBossMainView:checkBossIsInList(_id, _data)
	for i,v in ipairs(_data) do
		if _id == v._id then
			return true
		end
	end
	return false
end

function ShareBossMainView:updateUI(_tagType)
	self.curTagType = _tagType
	self:updateDetailView(self.selectedId, self.curTagType)
	self:updateSpineView(self.selectedId)
end

function ShareBossMainView:updateFrame()
	if self.isStop and self.isStop == true then
		return 
	end

    if self.leftTime == 0 then
        return
    end
    
    if self.frameCount % GameVars.GAMEFRAMERATE == 0 then
        local timeStr = TimeControler:turnTimeSec(self.leftTime - TimeControler:getServerTime(), TimeControler.timeType_dhhmmss)
        self.panel.panel_xinxi.txt_dtime:setString(timeStr) 

        for i,v in ipairs(self.indexDataMap) do
	    	local view = self.bottomScrollList:getViewByData(v)
	    	local leftTime = v.expireTime - TimeControler:getServerTime()	    	
	    	if leftTime == 0 then
	    		ShareBossModel:deleteExpireShareBossData(v._id)
	    		-- EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_NUM_CHANGED)
	    	else
	    		local timeStr = TimeControler:turnTimeSec(leftTime, TimeControler.timeType_dhhmmss)
	    		if view then
	    			view.txt_time:setString(timeStr)
	    		end	    		
	    	end
    	end

    end

    -- if self.frameCount % (GameVars.GAMEFRAMERATE * 10) == 0 then
    -- 	ShareBossModel:setAllBossDatas()
    -- end
    self.frameCount = self.frameCount + 1
end

function ShareBossMainView:initScrollCfg()
	self.panel.panel_latiao.panel_1:setVisible(false)

	local createCellFunc = function (_bossData, itemIndex)
        local _view = UIBaseDef:cloneOneView(self.panel.panel_latiao.panel_1)        		
		self.indexDataMap[itemIndex] = _bossData
		self:updateLatiaoCellView(_view, _bossData)
		return _view
    end

    local reuseUpdateCellFunc = function (_bossData, _view, itemIndex)
        self:updateLatiaoCellView(_view, _bossData)
        self.indexDataMap[itemIndex] = _bossData
        return _view;  
    end

	self._shareBossParmas = {
		{
			data = self.bossDatas,	        
	        createFunc = createCellFunc,
	        offsetX = 8,
	        offsetY = -125,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -6, width = 230, height = 133},
	        updateCellFunc = reuseUpdateCellFunc,
		}
	}

	self.bottomScrollList:styleFill(self._shareBossParmas)
	self.bottomScrollList:refreshCellView(1)
	self.bottomScrollList:hideDragBar()
end

function ShareBossMainView:updateLatiaoCellView(_view, _bossData)
	local curTime = TimeControler:getServerTime()
	local view = _view
	local bossData = FuncShareBoss.getBossDataById(tostring(_bossData.bossId))
	local name = FuncTranslate._getLanguage(bossData.name)
	local star = bossData.star
	local leftTime = TimeControler:turnTimeSec(_bossData.expireTime - curTime, TimeControler.timeType_dhhmmss)

	-- TODO需要根据得到的血量和总血量去计算
	local totalHp, curDamage = ShareBossModel:updateHpStatus(_bossData)
	-- local total_damage = self:getTotalDamageByRank(_bossData.totalDamages)
	local currentHp = totalHp - curDamage
	local percent = math.ceil(currentHp * 100 / totalHp)
	local percentTxt = percent.."%"
	view.txt_name:setString(name)
	view.mc_2:showFrame(tonumber(star))
	view.panel_eye:setVisible(false)
	view.panel_zhan:setVisible(true)
	view.panel_progress.progress_1:setPercent(percent)
	view.panel_progress.txt_1:setString(percentTxt)
	view.txt_time:setString(leftTime)
	view.mc_di:showFrame(tonumber(bossData.type))
	
	if self:checkHaveRank(_bossData) then
		view.panel_zhan:setVisible(true)
		view.panel_eye:setVisible(false)
	elseif _bossData._id == UserModel:rid() then
		view.panel_eye:setVisible(true)
		view.panel_zhan:setVisible(false)
	else
		view.panel_eye:setVisible(false)
		view.panel_zhan:setVisible(false)
	end

	-- 选中框状态
	if _bossData._id == self.selectedId then
        view.panel_xuan:setVisible(true)
    else
        view.panel_xuan:setVisible(false)
    end

	_view:setTouchedFunc(c_func(self.touchedItemView, self, _bossData._id))
end

function ShareBossMainView:updateSelectedStatusInScroll(_id)

    local _bossData = ShareBossModel:getBossDataById(_id)
    local currentCell = self.bottomScrollList:getViewByData(_bossData)

    if self.lastSelectCell ~= nil then
        self.lastSelectCell.panel_xuan:setVisible(false)
    end

    -- 设置当前选中为最近选中
    self.lastSelectCell = currentCell
    if self.lastSelectCell then
        self.lastSelectCell.panel_xuan:setVisible(true)
    end  
end

--该方法移到model中
-- function ShareBossMainView:updateHpStatus(_bossData)
-- 	local totalHp = 0
-- 	local currentHp = 0
-- 	local enemyHp = 0
-- 	local levelId = FuncShareBoss.getLevelIdById(tostring(_bossData.bossId))
-- 	local enemyIds = FuncShareBoss.getEnemyIdByLevelId(levelId)
-- 	for i, v in ipairs(enemyIds) do
-- 		if v ~= "" then
-- 			enemyHp = FuncShareBoss.getBossHpById(v, _bossData.bossId)
-- 			totalHp = totalHp + tonumber(enemyHp)
-- 		end
-- 	end

-- 	local damage = 0
-- 	if _bossData.bossHp == nil or _bossData.bossHp == {} then
-- 		currentHp = totalHp
-- 	else
-- 		for k,v in pairs(_bossData.bossHp) do
-- 			local id_table = string.split(k, "_")
-- 			local upperHp = FuncShareBoss.getBossHpById(id_table[1], _bossData.bossId)
-- 			if  tonumber(upperHp) < tonumber(v) then
-- 				v = upperHp
-- 			end
-- 			damage = damage + tonumber(v)
-- 		end
-- 	end
-- 	return totalHp, damage
-- end

function ShareBossMainView:getTotalDamageByRank(_rankDatas)
	local total_damage = 0
	if _rankDatas and table.length(_rankDatas) > 0 then
		for k,v in pairs(_rankDatas) do
			total_damage = total_damage + v.damage
		end
	end
	return total_damage
end

-- 根据tagsStr获得buff加成描述
function ShareBossMainView:getBuffDescription(_tagsStr)
	local tags = FuncCommon.splitStringIntoTable(_tagsStr)
	local name_table = {}
	for i,v in ipairs(tags) do
		local name = FuncCommon.getTagNameByTypeAndId(v[1], v[2])
		table.insert(name_table, name)
	end
	return name_table
end

function ShareBossMainView:updateDetailView(_id, _tagType)
	self.curTagType = _tagType
	self.selectedId = _id

	-- dump(self.rankDatas, "\n\nself.rankDatas== ")
	self:updateTagStatus(_tagType)
    local _bossData = ShareBossModel:getBossDataById(self.selectedId)
    self.rankDatas = _bossData.totalDamages
    local bossData = FuncShareBoss.getBossDataById(tostring(_bossData.bossId))
	local name = FuncTranslate._getLanguage(bossData.name)
	local star = bossData.star
	-- local liveTime = TimeControler:turnTimeSec(bossData.time, TimeControler.timeType_dhhmmss)
	local buffTxt_table = ShareBossMainView:getBuffDescription(_bossData.tagsStr)
	local attr = FuncShareBoss.getBuffAttrByBuffId(tostring(_bossData.buffId))
	local attr_addition = FuncBattleBase.getFormatFightAttrValueByMode(attr[1].key, attr[1].value, attr[1].mode)
	local buffTxt = ""
	local length = #buffTxt_table

	for i,v in ipairs(buffTxt_table) do
		local name = FuncTranslate._getLanguage(tostring(v))
		if i < length then
			name = name.."、"
		end
		buffTxt = buffTxt..name
	end
	self.buffDes = FuncTranslate._getLanguageWithSwap(FuncShareBoss.getBuffDesByBuffId(tostring(_bossData.buffId)), buffTxt, attr_addition)
	
	local rankReward1 = bossData.rankReward1
	local battleReward = bossData.battleReward
	local braveReward = bossData.braveReward
	local totalHp, curDamage = ShareBossModel:updateHpStatus(_bossData)
	-- local total_damage = self:getTotalDamageByRank(self.rankDatas)
	if self.selectedId == UserModel:rid() then
		self.panel.panel_xinxi.mc_1:showFrame(1)
	else
		self.panel.panel_xinxi.mc_1:showFrame(2)
	end
	local hasCount = 0
	if _bossData.challengeCounts and table.length(_bossData.challengeCounts) > 0 then
		for k,v in pairs(_bossData.challengeCounts) do
			if k == UserModel:rid() then
				hasCount = v
				break
			end
		end		
	end

	local countString = hasCount.." / "..self.maxCountEveryBoss
	if hasCount < self.maxCountEveryBoss then
		FilterTools.clearFilter(self.panel.panel_xinxi.mc_1.currentView)
	else
		FilterTools.setGrayFilter(self.panel.panel_xinxi.mc_1.currentView)
	end

	local currentHp = totalHp - curDamage
	local percent = math.ceil(currentHp * 100 / totalHp)
	local percentTxt = percent.."%"
	self.panel.panel_xinxi.panel_hp.txt_1:setString(percentTxt)
	self.panel.panel_xinxi.panel_hp.progress_jindu:setPercent((currentHp * 100 / totalHp))
	self.panel.panel_xinxi.txt_name:setString(name)
	self.panel.panel_xinxi.txt_cz2:setString(countString)
	self.panel.panel_xinxi.rich_ts:setString(GameConfig.getLanguage("#tid_ShareBoss_003")..self.buffDes)
	-- self.panel_xinxi.txt_dtime:setString(liveTime)
	if self.curTagType == self.selectTagType.TAG_XIANG_QING then
		if self.notGetReward == true then
			self.panel.panel_xinxi.mc_nr:showFrame(4)
		else
			self.panel.panel_xinxi.mc_nr:showFrame(1)
			local panel = self.panel.panel_xinxi.mc_nr.currentView
			
			for i = 1, 2 do
				local UIName = "UI_"
				local mc_l = panel["mc_l"..i]
				local reward_table = rankReward1
				if i == 2 then
					UIName = "UI_s"
					if CountModel:getShareBossChallengeCount() >= self.maxCountEveryDay then
						reward_table = braveReward
					else
						reward_table = battleReward
					end				
				end

				reward_table = FuncItem.getRewardArrayByCfgData(reward_table)
				local count = table.length(reward_table)
				if count > 3 then
					-- echo("\n\n配表中的奖励条数超过了3条，联系策划是否需要修改")
					count = 3
				end
				mc_l:showFrame(count)
				local panel_mc = mc_l.currentView
				for i = 1, count do
					local reward = string.split(reward_table[i], ",")
					local rewardType = reward[1]
					local rewardNum = reward[table.length(reward)]
					local rewardId = reward[table.length(reward) - 1]

					local commonUI = panel_mc[UIName .. tostring(i)]
					commonUI:setResItemData({reward = reward_table[i]})
					commonUI:showResItemName(false)
					commonUI:showResItemRedPoint(false)
					
			        FuncCommUI.regesitShowResView(commonUI,
			            rewardType, rewardNum, rewardId, reward_table[i], true, true)
			        if UIName == "UI_s" then
			        	commonUI:showResItemNum(true)
			        else
			        	commonUI:showResItemNum(false)
			        end
				end
			end
		end
	else

		if self.rankDatas and table.length(self.rankDatas) > 0 then
			-- dump(self.rankDatas, "\n\nself.rankDatas====")
			local sortedRankDatas = {}
			for k, v in pairs(self.rankDatas) do
				table.insert(sortedRankDatas, v)
			end
			table.sort(sortedRankDatas, function (a, b)
				return a.damage > b.damage
			end)
			for i,v in ipairs(sortedRankDatas) do
				v.rank = i
			end
			-- dump(sortedRankDatas, "\n\nsortedRankDatas====")
			self.panel.panel_xinxi.mc_nr:showFrame(2)
			self:updateRankScrollView(self.selectedId, sortedRankDatas)
		else
			self.panel.panel_xinxi.mc_nr:showFrame(3)
		end
		
	end
end

function ShareBossMainView:touchedItemView(_id)
	if self.selectedId == _id then
		return 
	end

	self.spineChanged = true
	self.lastSelectCell = self.bottomScrollList:getViewByData(ShareBossModel:getBossDataById(self.selectedId))
	self.selectedId = _id
	self.touchYeQian = false
	EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_RANK_DATA_CHANGED)
	-- local trid = ShareBossModel:getBossDataById(_id)._id
	-- local tsec = ShareBossModel:getBossDataById(_id).sec
	-- ShareBossModel:setShareBossRankData(trid, tsec)

	ShareBossModel:setSelectedId(_id)
end

function ShareBossMainView:updateRankScrollView(_id, _sortedRankDatas)
	-- TODO 排行数据
	local rankDatas = _sortedRankDatas

	self.rankPanel.panel_2:setVisible(false)

	local createCellFunc = function (_rankData)
        local view = UIBaseDef:cloneOneView(self.rankPanel.panel_2)        
		self:updateRankCellView(view, _rankData, _id)
		return view
    end

    local reuseUpdateCellFunc = function (_rankData, view)
        self:updateRankCellView(view, _rankData, _id)
        return view;  
    end

	local _rankParmas = {
		{
			data = rankDatas,	        
	        createFunc = createCellFunc,
	        offsetX = 0,
	        offsetY = -12,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -48, width = 512, height = 58},
	        updateCellFunc = reuseUpdateCellFunc,
		}
	}

	self.rankPanel.scroll_1:styleFill(_rankParmas)
	self.rankPanel.scroll_1:refreshCellView(1)
	self.rankPanel.scroll_1:hideDragBar()
end

-- function ShareBossMainView:checkBraveReward(_id)
-- 	if self.rescueUsers and table.length(self.rescueUsers) > 0 then
-- 		for k,v in pairs(self.rescueUsers) do
-- 			if tostring(k) == tostring(_id) then
-- 				return true
-- 			end
-- 		end
-- 	end
-- 	return false
-- end
-- TODO 排行展示
function ShareBossMainView:updateRankCellView(_view, _rankData, _id)
	local name = _rankData.name
	if name == "" then
		name = "少侠"
	end
	
	local damage = _rankData.damage
	local rank = _rankData.rank
	local rankRewards = FuncShareBoss.getRankRewardsById(tostring(ShareBossModel:getBossDataById(_id).bossId))
	local grade = 1
	local count = 1
	
	if #(tostring(damage)) > 8 then
		damage = math.floor(damage / 10000).." 万"
	end

	if tostring(_rankData.rid) == tostring(UserModel:rid()) then
		_view.rich_name:setString("<color = c52a00>"..name.."<->")
		_view.rich_pm:setString("<color = c52a00>"..damage.."<->")
	else
		_view.rich_name:setString("<color = 7d563c>"..name.."<->")
		_view.rich_pm:setString("<color = 0d8a0d>"..damage.."<->")
	end
	

	if rank <= FuncShareBoss.rankRange.THIRD then
		_view.mc_num:showFrame(rank)
		count = table.length(rankRewards[rank])
		_view.mc_xx:showFrame(count)
		grade = rank
	else
		_view.mc_num:showFrame(4)
		_view.mc_num.currentView.txt_1:setString(tostring(rank))
		if rank >= FuncShareBoss.rankRange.FORTH_LOWER and rank <= FuncShareBoss.rankRange.FORTH_UPPER then
			grade = FuncShareBoss.grade.FORTH						
		elseif rank >= FuncShareBoss.rankRange.FIFTH_LOWER and rank <= FuncShareBoss.rankRange.FIFTH_UPPER then
			grade = FuncShareBoss.grade.FIFTH			
		elseif rank >= FuncShareBoss.rankRange.SIXTH then
			grade = FuncShareBoss.grade.SIXTH
		end
	end

	
	if _rankData.isRescue then
		_view.mc_xx:setVisible(false)
	else
		_view.mc_xx:setVisible(true)
		local currentRankReward = FuncItem.getRewardArrayByCfgData(rankRewards[grade])
		count = table.length(currentRankReward)
		_view.mc_xx:showFrame(count)
		for i = 1, count do
			local reward = string.split(currentRankReward[i], ",")
			local rewardType = reward[1]
			local rewardNum = reward[table.length(reward)]
			local rewardId = reward[table.length(reward) - 1]

			local commonUI = _view.mc_xx.currentView["UI_" .. tostring(i)]
			commonUI:setResItemData({reward = currentRankReward[i]})
			commonUI:showResItemName(false)
			commonUI:showResItemRedPoint(false)
	        FuncCommUI.regesitShowResView(commonUI,
	            rewardType, rewardNum, rewardId, currentRankReward[i], true, true)
		end
	end	
end

function ShareBossMainView:updateSpineView(_id)
	if self.spineChanged == false then
		return 
	end

	-- echo("\n\n___________id_________====", _id)
	local _bossData = ShareBossModel:getBossDataById(_id)
	local bossData = FuncShareBoss.getBossDataById(tostring(_bossData.bossId))
	local levelId = bossData.levelId
	local bossSpineIds = bossData.spineId
	local star = bossData.star
	-- TODO 发现者的名字 传过来的为""时用  "少侠" 替代
	if _bossData.findUserName == "" then
		_bossData.findUserName = "少侠"
	end

	local finderName = "<color=c28856>发现人:<-> ".._bossData.findUserName

	-- if tonumber(bossData.type) == 1 then
		self.panel.mc_6ge:showFrame(1)
		self.panel.mc_6ge.currentView.panel_ren.ctn_1:removeAllChildren()
		local str_table = string.split(bossSpineIds[1], ",")
		local spineId = str_table[1]
		local scale = 1
		if str_table[2] then
			scale = str_table[2]
		end
		local sourceCfg = FuncTreasure.getSourceDataById(spineId)
		-- local spineName = sourceCfg.spine
		local bossView = FuncRes.getSpineViewBySourceId(spineId, nil, false, sourceCfg) 
		bossView:addto(self.panel.mc_6ge.currentView.panel_ren.ctn_1)
		bossView:setScale(scale)
	-- else
	-- 	self.panel.mc_6ge:showFrame(2)

	-- 	-- 因为一测资源已经封版暂时在这里做了强转换
	-- 	local spineIds = {}
	-- 	spineIds[1] = bossSpineIds[5]
	-- 	spineIds[2] = bossSpineIds[3]
	-- 	spineIds[3] = bossSpineIds[1]
	-- 	spineIds[4] = bossSpineIds[6]
	-- 	spineIds[5] = bossSpineIds[4]
	-- 	spineIds[6] = bossSpineIds[2]
	-- 	for i = 1, 6 do
	-- 		self.panel.mc_6ge.currentView.panel_ren["panel_ren"..i].ctn_1:removeAllChildren()
	-- 	end

	-- 	for i,v in ipairs(spineIds) do
	-- 		if tostring(v) ~= "" then
	-- 			-- self.panel.mc_6ge.currentView.panel_ren["panel_ren"..i].ctn_1:removeAllChildren()
	-- 			local str_table = string.split(v, ",")
	-- 			local spineId = str_table[1]
	-- 			local scale = 1
	-- 			if str_table[2] then
	-- 				scale = str_table[2]
	-- 			end

	-- 			local sourceCfg = FuncTreasure.getSourceDataById(spineId)
	-- 			-- local spineName = sourceCfg.spine
	-- 			local bossView = FuncRes.getSpineViewBySourceId(spineId, nil, false, sourceCfg)
	-- 			bossView:addto(self.panel.mc_6ge.currentView.panel_ren["panel_ren"..i].ctn_1)
	-- 			bossView:setScale(scale)
	-- 		end			
	-- 	end
	-- end
	self.panel.mc_6ge.currentView.panel_ren.mc_star:showFrame(tonumber(star))
	self.panel.panel_hz.rich_1:setString(finderName)
	self.spineChanged = false
end

function ShareBossMainView:touchedYeQian(_tagType)
	if self.curTagType == _tagType then
		return 
	end

	self.curTagType = _tagType
	self.touchYeQian = true
	self:updateDetailView(self.selectedId, _tagType)
end

function ShareBossMainView:updateTagStatus(_tagType)
	self.tagPanel:setVisible(true)
    for i= 1, 2 do
        self.tagPanel["mc_yeqian" .. i]:setVisible(true)
        if i == _tagType then
            self.tagPanel["mc_yeqian" .. i]:showFrame(2)
        else
            self.tagPanel["mc_yeqian" .. i]:showFrame(1)
        end
    end
end

function ShareBossMainView:close()
	self:startHide()
end

function ShareBossMainView:deleteMe()
	-- TODO
	ShareBossMainView.super.deleteMe(self);
end

return ShareBossMainView;
