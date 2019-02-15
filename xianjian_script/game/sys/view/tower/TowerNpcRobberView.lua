--
--Author:      zhuguangyuan
--DateTime:    2017-12-22 11:21:53
--Description: 锁妖塔npc类型 险地拦路者 随机劫财劫色劫魔石
--


local TowerNpcRobberView = class("TowerNpcRobberView", UIBase);

function TowerNpcRobberView:ctor(winName,npcID,npcPos,resistReward)
    TowerNpcRobberView.super.ctor(self, winName)
    self.npcId = npcID or 1004
    self.npcPos = npcPos 
    --- 打败抢劫者的奖励
    self.resistReward = resistReward
    if self.resistReward then
    	self.isSolveEvent = true
    end
end

function TowerNpcRobberView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	self:initBubble( self.panel_qipao )
	-- 	local _params = {
	-- }
	-- TowerMainModel:saveNPCRobberRobData( _params )
end 


-- function TowerNpcRobberView:onBecomeTopView()
-- 	if self.robType and self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE
-- 		and self.robId and 
-- end
-- 弹出气泡
function TowerNpcRobberView:initBubble( _popupView )
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(2.5)
	local scaleto_3 = act.scaleto(0.1,0)
	local delaytime_3 = act.delaytime(0.5)
	local callfun = act.callfunc(function ()
		self:updateNPCWords(_popupView)
	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	_popupView:runAction(act._repeat(seqAct))
end
-- 更新气泡里的话
function TowerNpcRobberView:updateNPCWords(_popupView)
	_popupView.txt_1:setString(self.currentWords)
end

-- 进战斗缓存
function TowerNpcRobberView:getEnterBattleCacheData()
    echo("\n 战斗前缓存view数据 TowerNpcRobberView")
    return  {
                robType = self.robType,
                robId = self.robId,
                mapTypeToEventId = self.mapTypeToEventId,
            }
end
-- 战斗恢复
function TowerNpcRobberView:onBattleExitResume(cacheData )
    dump(cacheData,"战斗恢复view TowerNpcRobberView")
    TowerNpcRobberView.super.onBattleExitResume(cacheData)
    if TowerMainModel:checkBattleWin() then
    	self:startHide()
    	return
    end

    if cacheData and cacheData.robType then
    	self.robType = cacheData.robType
    	self.robId = cacheData.robId
    	self.mapTypeToEventId = cacheData.mapTypeToEventId

    	-- 被劫女性奇侠在抗争中死亡,重新随机一个女性伙伴
    	if self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN
    		and TeamFormationSupplyModel:checkIsDead(self.robId, FuncTeamFormation.formation.pve_tower) 
    	then
    		self.robId = nil
    		echo("_______女性伙伴死亡,重新随机_________")
    		self:randomRobId()
    	end
    end
end

function TowerNpcRobberView:registerEvent()
	TowerNpcRobberView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close,self))
    EventControler:addEventListener(TowerEvent.TOWEREVENT_REFRESH_RANDOM_FEMALE_PARTNER,self.reCheckFemaleAliveStatus,self)
end

function TowerNpcRobberView:reCheckFemaleAliveStatus()
    echo("_______重新检查!!! 女性伙伴死亡,重新随机_________")
	if self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN
		and TeamFormationSupplyModel:checkIsDead(self.robId, FuncTeamFormation.formation.pve_tower) 
	then
		self.robId = nil
		echo("_______女性伙伴死亡,重新随机_________")
		self:randomRobId()
		self:updateUI()
	end
end

function TowerNpcRobberView:initData()
	self.npcData = FuncTower.getNpcData(self.npcId)
	local params = TowerMainModel:getNPCRobberRobData()
	if params and params.robType then
		self.robType = params.robType
    	self.robId = params.robId
    	self.eventId = params.eventId
    	self.mapTypeToEventId = params.mapTypeToEventId
    end
    dump(params, "params")
    -- 被劫女性奇侠在抗争中死亡,重新随机一个女性伙伴
	echo("_____ TeamFormationSupplyModel:checkIsDead(self.robId) ________",TeamFormationSupplyModel:checkIsDead(self.robId, FuncTeamFormation.formation.pve_tower))
	if self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN
		and TeamFormationSupplyModel:checkIsDead(self.robId, FuncTeamFormation.formation.pve_tower) 
		and not self.resistReward 
	then
		self.robId = nil
		self:randomRobId()
	end
	self:randomRobType()
	self:randomRobId()
end

-- 随机 打劫类型 劫财劫色劫魔石
function TowerNpcRobberView:randomRobType()
	if self.robType then
		return
	end
	local eventArr = {}
	if not self.npcData.event then
		return
	end

	-- 可根据事件类型反向获取其事件id 
	self.mapTypeToEventId = {}

	for k,v in ipairs(self.npcData.event) do
		local data1 = FuncTower.getNpcEvent(v)
		local typ1 = data1.type 
		self.mapTypeToEventId[typ1] = v
		-- 劫法宝,如果法宝只有一个则不劫
		if typ1 == FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE then
			local rt = self:getAllTreasureIds()
			if #rt > 1 then
				eventArr[#eventArr+1] = FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE
			end
		end
		-- 劫女人 有就劫
		if typ1 == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN then
			local rt = self:getAllFemalePartnerIds()
		    if #rt > 0 then
				eventArr[#eventArr+1] = FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN
			end
		end
	end
	dump(eventArr, "eventArr")

	local rt = FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE
	if #eventArr ~= 0 then
		local randomType = RandomControl.getNumsByGroup(eventArr,1)
		rt = randomType[1]
	end
	self.robType = rt 
	self.eventId = self.mapTypeToEventId[self.robType]
	echo("______随机结果 self.robType___________",self.robType)
	echo("______随机结果 self.eventId___________",self.eventId)
end

function TowerNpcRobberView:getAllTreasureIds()
	local treasures = TreasureNewModel:getOwnTreasures()
	local banTreasures = TowerMainModel:towerExt().banTreasures or {}
	local rt = {}
	for k2,v in pairs(treasures) do
		if not table.isKeyIn(banTreasures,k2) then
			rt[#rt + 1] = v.id
		end
    end
    return rt
end

function TowerNpcRobberView:getAllFemalePartnerIds()
	local partners = PartnerModel:getAllPartner()
	local banPartners = TowerMainModel:towerExt().banPartners or {}
    local rt = {}
    for k,v in pairs(partners) do
		local partnerConfigData = FuncPartner.getPartnerById(k)
		if partnerConfigData.sex == FuncPartner.PARTNER_SEX.FEMALE 
			and not TeamFormationSupplyModel:checkIsDead(k, FuncTeamFormation.formation.pve_tower)
			and not table.isKeyIn(banPartners,k)
		then
			rt[#rt + 1] = k
		end
    end
    return rt
end

-- 随机打劫的女性伙伴id 或者 法宝id 或者魔石的数量(也当做id处理)
function TowerNpcRobberView:randomRobId()
	if self.robId then
		return
	end
	if not self.robType then
		self:randomRobType()
	end

	if tostring(self.robType) == tostring(FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE) then
		local rt = self:getAllTreasureIds()
		if #rt == 0 then
			self.robType = nil
			self:randomRobId()
		else
			self.robId = RandomControl.getNumsByGroup(rt,1)[1]
		end
	elseif tostring(self.robType) == tostring(FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN) then
		local rt = self:getAllFemalePartnerIds()
		if #rt == 0 then
			self.robType = nil
			self:randomRobId()
		else
			self.robId = RandomControl.getNumsByGroup(rt,1)[1]
		end
	elseif tostring(self.robType) == tostring(FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE) then
		self.robId = UserModel:getDimensity()
		local evenrData = FuncTower.getNpcEvent(self.eventId)
		local costData = evenrData.cost[1]
		local costArray = string.split(costData,",") 
		-- echo("______ costArray[2] ______",costArray[2])
		if tonumber(costArray[2]) < tonumber(UserModel:getDimensity()) then
			self.robId = costArray[2]
		end
	end
	local _params = {
		robType = self.robType ,
    	robId = self.robId ,
    	eventId = self.eventId,
    	mapTypeToEventId = self.mapTypeToEventId ,
	}
	TowerMainModel:saveNPCRobberRobData( _params )
	echo("______随机结果细化 self.robId ___________",self.robId)
end
function TowerNpcRobberView:initView()
	self.UI_1.mc_1:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage(self.npcData.name))
end

function TowerNpcRobberView:initViewAlign()
	-- TODO
end

function TowerNpcRobberView:updateUI()
	-- test code
	-- self.robType = FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE 
	-- self.robId = "304"

	if not self.isSolveEvent then
		if self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE 
			or self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE 
		then
			-- self.panel_qipao.txt_1:setString(GameConfig.getLanguage(self.npcData.qipao1[1]))
			local words = GameConfig.getLanguage(self.npcData.qipao1[1])
			self.currentWords = words
			-- self:popupBubble( self.panel_qipao,words )
			self.mc_1:showFrame(1)

			local iconPath = nil
    		local treasureIcon = nil
			if self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE then
				local rewardStr = "10," .. self.robId .. ",1"
				local rewardUI = self.mc_1.currentView.UI_1
				local params = {
		            reward = rewardStr,
		        }

        		rewardUI:setResItemData(params)
        		rewardUI:showResItemName(true,true,nil,true)
        		rewardUI:showResItemNum(false)
        		rewardUI:showResItemNameWithQuality()
        		rewardUI:setResItemIconScale(1.8)
				--[[
				iconPath = FuncRes.iconTreasureNew(self.robId)
	    		treasureIcon = display.newSprite(iconPath)
	    		treasureIcon:scale(0.8)
	    		local treasureName = FuncTreasureNew.getTreasureName(self.robId)
	    		treasureName = GameConfig.getLanguage(treasureName)
	    		local panelView = self.mc_1.currentView.UI_1.mc_1.currentView.btn_1:getUpPanel().panel_1
	    		if self.mc_1.currentView.UI_1.mc_1.currentView.btn_1:getUpPanel().panel_1.panel_skin then
	    			self.mc_1.currentView.UI_1.mc_1.currentView.btn_1:getUpPanel().panel_1.panel_skin:setVisible(false)
	    		end
	    		panelView.mc_zi.currentView.txt_1:setString(treasureName)
	    		panelView.mc_zi:setVisible(false)
	    		panelView.panel_red:visible(false)
	    		panelView.txt_goodsshuliang:visible(false)
	    		panelView.ctn_2:removeAllChildren()
    			panelView.ctn_2:addChild(treasureIcon)
    			]]
    			self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.beatTheBadBoy,self))
				self.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.giveHimWhatHimWant,self))
	    	else
	    		local rwd = {}
	    		-- 锁妖塔魔石可能在劫财劫色过程中 去商店买东西消耗了 
	    		if UserModel:getDimensity() < tonumber(self.robId) then
	    			self.robId = UserModel:getDimensity()
	    		end
	    		local num = self.robId

	    		rwd.reward = "30,"..num..""
	    		echo("rwd.reward",rwd.reward)
	    		self.mc_1.currentView.UI_1:setRewardItemData(rwd)
	    		treasureIcon = display.newSprite(FuncRes.iconRes(FuncDataResource.RES_TYPE.DIMENSITY))
	    		-- self.mc_1.currentView.btn_1:visible(false)--setTouchedFunc(c_func(self.beatTheBadBoy,self))
	    		local posX = self.mc_1.currentView.btn_2:getPositionX()  --getPositionX(x) 
	    		-- self.mc_1.currentView.btn_2:setPositionX(posX-90)
    			self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.beatTheBadBoy,self))
				self.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.giveHimWhatHimWant,self))
	    	end

		elseif self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN then
			-- self.panel_qipao.txt_1:setString(GameConfig.getLanguage(self.npcData.qipao1[2]))
			local words = GameConfig.getLanguage(self.npcData.qipao1[2])
			self.currentWords = words
			-- self:popupBubble( self.panel_qipao,words )
			self.mc_1:showFrame(2)
			self.mc_1.currentView.UI_1:updataUI(self.robId)

			self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.beatTheBadBoy,self))
			self.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.giveHimWhatHimWant,self))
		end
	else
		local _params = {
		}
		TowerMainModel:saveNPCRobberRobData( _params )
		local words = GameConfig.getLanguage(self.npcData.qipao3[1])
		if self.resistReward then
			self.compesationData = self.resistReward 
			words = GameConfig.getLanguage(self.npcData.qipao4[1])
		end
		self.currentWords = words
		-- self:popupBubble( self.panel_qipao,words )
		-- self.panel_qipao.txt_1:setString(words)
		self.mc_1:showFrame(3)
		-- local eventData = FuncTower.getNpcEvent(self.eventId)
	    local rwd = {}
		rwd.reward = self.compesationData[1] 
		dump(self.resistReward, "======== 服务器给的奖励数据 self.resistReward")
		dump(rwd, "============ rwd")
	    self.mc_1.currentView.UI_1:setRewardItemData(rwd)
	    -- self.mc_1.currentView.UI_1.mc_1:setRewardItemData(rwd)
		self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.getCompesation,self))
	end
end

-- 打他!
function TowerNpcRobberView:beatTheBadBoy()
	local levelId = FuncTower.getLevelIdByNpcEventId(self.eventId)
	local params = {	
		x = self.npcPos.x,
		y = self.npcPos.y,
		eventId = self.eventId,
		npcId = self.npcId, --- 用于战斗胜利后显示已经不存在的npc事件相关界面
	}
	params[FuncTeamFormation.formation.pve_tower] = {raidId = levelId}
	WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve_tower,params,false,false,true)
	-- self:startHide()
end

-- 给他 想要的 
function TowerNpcRobberView:giveHimWhatHimWant()
	if self.robType == FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE then	    	
		if UserModel:getDimensity() < tonumber(self.robId) then
			self.robId = UserModel:getDimensity()
		end
	end
	local params = {	
		x = self.npcPos.x,
		y = self.npcPos.y,
		eventId = self.eventId,
		value = self.robId,
	}
	TowerServer:robSomething(params,c_func(self.yieldToRobberCallback,self))
end
function TowerNpcRobberView:yieldToRobberCallback( serverData )
	dump(serverData.result, "desciption")
	if serverData.error then
		 WindowControler:showTips("NPC事件 投降 报错")
	else
		-- dump(serverData.result.data, "serverData.result.data")
		TowerMainModel:updateData(serverData.result.data)
		self:saveCompesationData(serverData.result.data.reward)
		self.isSolveEvent = true
		self:updateUI()
	end
	-- self:startHide()
end

function TowerNpcRobberView:saveCompesationData( _data )
	self.compesationData = _data
end

-- 领取补偿
function TowerNpcRobberView:getCompesation()
	local function _showcallBack()
		self:startHide()
	end
	FuncCommUI.startFullScreenRewardView(self.compesationData,_showcallBack)
end

function TowerNpcRobberView:press_btn_close()
	self:startHide()
end

function TowerNpcRobberView:deleteMe()
	-- TODO

	TowerNpcRobberView.super.deleteMe(self);
end

return TowerNpcRobberView;
