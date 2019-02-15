--[[
	Author: TODO
	Date:2018-01-19
	Description: TODO
]]

local EndlessBossDetailView = class("EndlessBossDetailView", UIBase);

function EndlessBossDetailView:ctor(winName, _endlessId)
    EndlessBossDetailView.super.ctor(self, winName)
    self.endlessId = tonumber(_endlessId)
end

function EndlessBossDetailView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EndlessBossDetailView:registerEvent()
	EndlessBossDetailView.super.registerEvent(self);

	self.scale9_2:setTouchedFunc(GameVars.emptyFunc, nil, true)
	local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self.ctn_bg, 0)
    coverLayer:pos(-GameVars.width / 2 - (GameVars.width-GameVars.gameResWidth)/2,  GameVars.height / 2)
    coverLayer:setTouchedFunc(c_func(self.needHideDetailView, self))
    coverLayer:setTouchSwallowEnabled(true)

	self.btn_gl:setTouchedFunc(c_func(self.showStrategyView, self))
	self.mc_btn:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.clickBattle, self))
	EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.enterBattle, self)
end

function EndlessBossDetailView:needHideDetailView()
    EventControler:dispatchEvent(EndlessEvent.CLOSE_BOSS_DETAIL_VIEW)
end

function EndlessBossDetailView:setEndlessId(_endlessId)
	self.endlessId = tonumber(_endlessId)
	self:initData()
	self:initView()
	self:updateUI()
end

function EndlessBossDetailView:initData()
	self.endlessData = FuncEndless.getLevelDataById(self.endlessId)
	self.starRewards = {
		[1] = self.endlessData.starReward1,
		[2] = self.endlessData.starReward2,
		[3] = self.endlessData.starReward3,
	}
	self.friendAndGuildData = EndlessModel:getFriendAndGuildData()
	self:getFriendAndGuildEndlessData()
	self._curStar = EndlessModel:getStatusByEndlessId(self.endlessId)
	self.index = 1
end

--获取通过当前endlessId的好友和盟友数据
function EndlessBossDetailView:getFriendAndGuildEndlessData()
	self.friendList = self.friendAndGuildData.friends or {}
	self.guildList = self.friendAndGuildData.members or {}
	self.allDataList = EndlessModel:getFriendAndGuildEndlessData(self.friendList, self.guildList, self.endlessId)
end

function EndlessBossDetailView:initView()
	self.mc_btn:showFrame(1)
	-- self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_endless_tips_5"))
	local floor, section = FuncEndless.getFloorAndSectionById(self.endlessId)
	local totalSection = FuncEndless.getSectionNumById(floor)
	local bossName = GameConfig.getLanguageWithSwap("#tid_endless_name_4", floor, section)
	self.txt_guanqia:setString(bossName)
	if section == totalSection then
		self.RankAndCommentd_type = FuncRankAndcomments.RankAndCommentd_type.rankAndComment
	else
		self.RankAndCommentd_type = FuncRankAndcomments.RankAndCommentd_type.rank
	end
	
	self._wave = FuncEndless.waveNum.FIRST
	self:updateHavePassedAnim()
	self:updateButtonStatus()
end

function EndlessBossDetailView:updateHavePassedAnim()
	local passedNums = #self.allDataList
	local nameStr = ""
	if passedNums > 0 then
		self.panel_player:setVisible(true)
		self.playerView = self:updateOnePassedView()
		self.playerView:stopAllActions()
		local resetPosAndData = function ()
			self.index = self.index + 1
			if self.index <= passedNums then
				local itemData = self.allDataList[self.index]
				self:updateIconAndName(self.playerView, itemData)
			else
				self.index = 1
				local itemData = self.allDataList[self.index]
				self:updateIconAndName(self.playerView, itemData)
			end	
			self.playerView:pos(20, -50)
		end
		local moveInFunc = function ()		
			local spawnAct = act.sequence(act.spawn(act.moveto(0.5, 20, -5), act.fadein(0.5)))
			self.playerView:runAction(spawnAct)
		end

		local moveOutFunc = function ()		
			local spawnAct = act.sequence(act.spawn(act.moveto(0.5, 20, 50), act.fadeout(0.5)))
			self.playerView:runAction(spawnAct)
		end

		local seqAct = act.sequence(act.callfunc(moveInFunc), act.delaytime(4), act.callfunc(moveOutFunc), act.fadeout(0.5), 
	 			act.callfunc(resetPosAndData), act.delaytime(1))
		self.playerView:runAction(act._repeat(seqAct))
	else
		if self.playerView then
			self.playerView:stopAllActions()
		end
		self.panel_player:setVisible(false)
	end	
end

function EndlessBossDetailView:updateOnePassedView()
	local itemData = self.allDataList[self.index]
	local head = itemData.head
	local frame = itemData.frame
	local iconId = FuncUserHead.getHeadIcon(head, avatar)
	local playerView = self.panel_player.panel_pass
	local endlessMask = display.newSprite(FuncRes.iconOther("endless_zhezhao"))
	endlessMask:anchor(0, 1)
	endlessMask:setScale(1)
	local iconSprite = display.newSprite(FuncRes.iconHero(iconId))
	self:updateIconAndName(playerView, itemData)
	self.panel_player:pos(25, 0)
	local passView = FuncCommUI.getMaskCan(endlessMask, self.panel_player)
	passView:addto(self.ctn_pass)
	passView:pos(-10, 0)
	playerView:pos(20, -50)
	-- self.panel_player.panel_di:pos(0, -5)
	return playerView
end

function EndlessBossDetailView:updateIconAndName(_view, itemData)
	local _width = FuncCommUI.getStringWidth(itemData.name, 20)
	_view.txt_1:setString(itemData.name)
	_view.txt_2:pos(50 + _width, -17)
	local avatar = itemData.avatar
	local head = itemData.head
	local frame = itemData.frame
	local iconId = FuncUserHead.getHeadIcon(head, avatar)
    local iconSprite = display.newSprite(FuncRes.iconHero(iconId))
    local frameIcon = FuncUserHead.getHeadFramIcon(frame)
    local frameSprite = display.newSprite(FuncRes.iconHero(frameIcon))
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(0,0)
    iconSprite = FuncCommUI.getMaskCan(headMaskSprite, iconSprite)
    iconSprite:setScale(1.1)
    frameSprite:setScale(1.1)
    iconSprite:pos(-2, 2)
    frameSprite:pos(-2, 2)
    _view.panel_tx.ctn_1:removeAllChildren()
    _view.panel_tx.ctn_1:addChild(iconSprite)
    _view.panel_tx.ctn_1:addChild(frameSprite)
end

function EndlessBossDetailView:initViewAlign()
	-- TODO
end

function EndlessBossDetailView:updateUI()
	self.mc_right:showFrame(1)
	local panel_right = self.mc_right.currentView
	for i = 1, 3, 1 do
		local starRewards = self.starRewards[i]
		local view = panel_right["panel_jiangli"..i]
		local _type = i
		self:updateStarRewards(starRewards, view, _type)
	end
end

-- 加载未完美通关时右侧奖励界面
function EndlessBossDetailView:updateStarRewards(_starRewards, _view, _type)
	_view.mc_2:showFrame(tonumber(_type))
	local rewardNum = #_starRewards
	_view.mc_1:showFrame(rewardNum)
	for i = 1, rewardNum, 1 do
		local commonUI = _view.mc_1.currentView["panel_"..i].UI_1
		local reward = string.split(_starRewards[i], ",")
		local rewardType = reward[1]
		local rewardNum = reward[table.length(reward)]
		local rewardId = reward[table.length(reward) - 1]
		commonUI:setResItemData({reward = _starRewards[i]})
		commonUI:showResItemName(false)
		commonUI:showResItemRedPoint(false)
		commonUI:showResItemNum(true)
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, _starRewards[i], true, true)
        --暂时隐藏了是否已领取panel
        if self._curStar >= tonumber(_type) then
        	_view.mc_1.currentView["panel_"..i].panel_1:setVisible(true)
        else
        	_view.mc_1.currentView["panel_"..i].panel_1:setVisible(false)
        end
        
	end
end

--点击挑战
function EndlessBossDetailView:clickBattle()
	if self.endlessId > EndlessModel:getHistoryEndlessId() + 1 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_endless_tips_2"))
		return 
	else
		local status = EndlessModel:getStatusByEndlessId(self.endlessId)

		--无底深渊分为两波战斗  拥有两个levelId
		local levelId1 = FuncEndless.getFirstLevelIdById(self.endlessId)
		local levelId2 = FuncEndless.getSecondLevelIdById(self.endlessId)
		if status == FuncEndless.endlessStatus.THREE_STAR then
			WindowControler:showTips(GameConfig.getLanguage("#tid_endless_tips_1"))
			return 
		end

		EndlessModel:setCurChallengeEndlessId(self.endlessId)
		local params = {}
		params[FuncTeamFormation.formation.endless] = {
	 	    endlessId = self.endlessId,
	 	    raidId = levelId1,
	 	    secondRaidId = levelId2,
	  	} 
		WindowControler:showWindow("WuXingTeamEmbattleView", FuncTeamFormation.formation.endless, params)	
	end	
end

function EndlessBossDetailView:enterBattle(params)
	local params = params.params
	
	EndlessServer:setCurParams(params)
	local formation = {}
	formation.id = params.formation.id
	formation.partnerFormation = params.formation.partnerFormation
	formation.treasureFormation = params.formation.treasureFormation

	if params.systemId == FuncTeamFormation.formation.endless then
		local endlessId = params.params[FuncTeamFormation.formation.endless].endlessId
		local wave = FuncEndless.waveNum.FIRST
		EndlessServer:challengeEndless(endlessId, formation, c_func(self.onEnterBattle, self), wave)
	end
end

function EndlessBossDetailView:onEnterBattle(data )
	if data.result then
		local serviceData = data.result.data.battleInfo
		-- dump(serviceData,"s0------")
		local battleInfo = BattleControler:turnServerDataToBattleInfo(serviceData)
		EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
		EndlessModel:setChallengeNewEndless(self.endlessId)
		EventControler:dispatchEvent(EndlessEvent.CLOSE_BOSS_DETAIL_VIEW)
		BattleControler:startBattleInfo(battleInfo)
		EndlessModel:cacheBattleUsers(battleInfo.battleUsers[1])
	end
end

function EndlessBossDetailView:close()
	echo("\n\n______close________")
	EndlessModel:setCurEndlessId(nil)
	self:startHide()
end

--显示攻略界面
function EndlessBossDetailView:showStrategyView()
	local arrayData = {
        systemName = FuncCommon.SYSTEM_NAME.ENDLESS,---系统名称
        diifID = self.endlessId,  --关卡ID
        _type = self.RankAndCommentd_type, --评论类型
    }
    RankAndcommentsControler:showUIBySystemType(arrayData)
end

function EndlessBossDetailView:updateButtonStatus()
	--根据已通关的星级去显示
	if self._curStar == FuncEndless.endlessStatus.NOT_PASS then				
		if self.endlessId > EndlessModel:getHistoryEndlessId() + 1 then
			FilterTools.setGrayFilter(self.mc_btn.currentView.btn_1)
		else
			FilterTools.clearFilter(self.mc_btn.currentView.btn_1)
		end
	else
		if self._curStar == FuncEndless.endlessStatus.THREE_STAR then
			FilterTools.setGrayFilter(self.mc_btn.currentView.btn_1)
		else
			FilterTools.clearFilter(self.mc_btn.currentView.btn_1)
		end
	end
end

function EndlessBossDetailView:deleteMe()
	-- TODO

	EndlessBossDetailView.super.deleteMe(self);
end

return EndlessBossDetailView;
