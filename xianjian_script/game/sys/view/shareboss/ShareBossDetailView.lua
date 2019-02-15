--[[
	Author: TODO
	Date:2018-07-11
	Description: TODO
]]

local ShareBossDetailView = class("ShareBossDetailView", UIBase);

function ShareBossDetailView:ctor(winName, mainView, _data)
    ShareBossDetailView.super.ctor(self, winName)
    self.mainView = mainView
    self._data = _data
    ShareBossModel:setCurrentDetailData(self._data)
end

function ShareBossDetailView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ShareBossDetailView:registerEvent()
	ShareBossDetailView.super.registerEvent(self);

	--加一层透明的layer 用于点击界面外任意地方关闭界面
	local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self.ctn_1, 0)
    coverLayer:pos(-GameVars.width / 2,  GameVars.height / 2)
    coverLayer:setTouchedFunc(c_func(self.needHideBossDetailView, self), nil, true)

    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.enterBattle, self)

    self.mc_1:getViewByFrame(1).scale9_1:setTouchedFunc(GameVars.emptyFunc, nil, true)
    self.mc_1:getViewByFrame(2).scale9_1:setTouchedFunc(GameVars.emptyFunc, nil, true)

    self.btn_1:setTouchedFunc(c_func(self.switchToPreviousBossView, self))
    self.btn_2:setTouchedFunc(c_func(self.switchToNextBossView, self))
end

--切换到上一个boss
function ShareBossDetailView:switchToPreviousBossView()
	self.mainView:switchToPreviousBossView()
end

--切换到下一个boss
function ShareBossDetailView:switchToNextBossView()
	self.mainView:switchToNextBossView()
end

function ShareBossDetailView:initData()
	self.maxCountEveryBoss = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryBoss")
    self.maxCountEveryDay = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryDay")
    self.maxShareBossRescue = FuncDataSetting.getDataByConstantName("MaxShareBossRescue")
    self.maxChallengeCount = self.maxCountEveryDay + self.maxShareBossRescue
end

function ShareBossDetailView:initView()
	self.panel_1:setVisible(false)
	self.panel_2:setVisible(false)
	-- self.panel_3:setVisible(false)

	self.txt_1:setVisible(false)
	self.txt_2:setVisible(false)
end

function ShareBossDetailView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1, UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_1, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_2, UIAlignTypes.Left)
end

function ShareBossDetailView:updateUI()
	if self._data.isDead then
		self.mc_1:showFrame(2)
	else
		self.mc_1:showFrame(1)
		self:updateRewardAndDescription()
		self:updateBattleBtn()
	end

	self.scrollView = self.mc_1.currentView.scroll_1
	self:updateScrollView()
end

function ShareBossDetailView:updateShareBossView(_data)
	self._data = _data
	ShareBossModel:setCurrentDetailData(self._data)
	self:updateUI()
end

--发送隐藏详情界面事件
function ShareBossDetailView:needHideBossDetailView()
	ShareBossModel:setCurrentDetailData(nil)
	EventControler:dispatchEvent(ShareBossEvent.HIDE_BOSS_DETAILVIEW)
end

function ShareBossDetailView:setLeftBtnOpacity(opacity)
	self.btn_1:opacity(opacity)
	self.btn_2:opacity(opacity)
end

function ShareBossDetailView:setLeftBtnFideIn()
	self.btn_1:fadeIn(0.2)
	self.btn_2:fadeIn(0.2)
end

function ShareBossDetailView:updateRewardAndDescription()
    local bossData = FuncShareBoss.getBossDataById(tostring(self._data.bossId))
	local name = FuncTranslate._getLanguage(bossData.name)
	local star = bossData.star
	local buffTxt_table = FuncShareBoss.getBuffDescription(self._data.tagsStr)
	local attr = FuncShareBoss.getBuffAttrByBuffId(tostring(self._data.buffId))
	local attr_addition = FuncBattleBase.getFormatFightAttrValueByMode(attr[1].key, attr[1].value, attr[1].mode)
	local buffTxt = ""
	local length = #buffTxt_table

	--拼接战斗贴士描述
	for i,v in ipairs(buffTxt_table) do
		local name = FuncTranslate._getLanguage(tostring(v))
		if i < length then
			name = name.."、"
		end
		buffTxt = buffTxt..name
	end
	self.buffDes = FuncTranslate._getLanguageWithSwap(FuncShareBoss.getBuffDesByBuffId(tostring(self._data.buffId)), buffTxt, attr_addition)
	self.mc_1.currentView.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_shareboss_405", self.buffDes))

	--根据不同的参战次数和状态 显示不同的奖励和状态 （5次以上只获得侠义值 且没有击杀奖励）
	self.mc_1.currentView.mc_2:setVisible(false)
	self.mc_1.currentView.mc_3:setVisible(false)
	self.mc_1.currentView.txt_5:setVisible(false)
	self.mc_1.currentView.txt_6:setVisible(false)
	if CountModel:getShareBossChallengeCount() < self.maxChallengeCount then
		if CountModel:getShareBossChallengeCount() >= self.maxCountEveryDay then
			self:updateRewardView(bossData.braveReward, self.mc_1.currentView.mc_2)
			self.mc_1.currentView.mc_2:setVisible(true)
			self.mc_1.currentView.txt_5:setVisible(true)
		else
			self:updateRewardView(bossData.battleReward, self.mc_1.currentView.mc_2)
			self:updateRewardView(bossData.killReward, self.mc_1.currentView.mc_3)
			self.mc_1.currentView.mc_2:setVisible(true)
			self.mc_1.currentView.mc_3:setVisible(true)
			self.mc_1.currentView.txt_5:setVisible(true)
			self.mc_1.currentView.txt_6:setVisible(true)
		end
	end
end

--加载奖励
function ShareBossDetailView:updateRewardView(rewards, mcView)
	local reward_table = FuncItem.getRewardArrayByCfgData(rewards)
	local count = table.length(reward_table)
	if count > 3 then
		count = 3
	end

	mcView:showFrame(count)
	local panel_mc = mcView.currentView
	for i = 1, count do
		local reward = string.split(reward_table[i], ",")
		local rewardType = reward[1]
		local rewardNum = reward[table.length(reward)]
		local rewardId = reward[table.length(reward) - 1]

		local commonUI = panel_mc["UI_"..i]
		commonUI:setResItemData({reward = reward_table[i]})
		commonUI:showResItemName(false)
		commonUI:showResItemRedPoint(false)
		
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, reward_table[i], true, true)
	end
end

--更新战斗按钮状态
function ShareBossDetailView:updateBattleBtn()
	if CountModel:getShareBossChallengeCount() >= self.maxChallengeCount then
		self.mc_1.currentView.btn_1:setVisible(false)
		return
	end
	self.canzhanCount = 0
	if self._data.challengeCounts and table.length(self._data.challengeCounts) > 0 then
		for k,v in pairs(self._data.challengeCounts) do
			if k == UserModel:rid() then
				self.canzhanCount = v
				break
			end
		end		
	end

	if self._data.open and self._data.open == 1 and self.canzhanCount < self.maxCountEveryBoss then
		self.mc_1.currentView.btn_1:setVisible(true)
		self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.clickBattle, self))
	else
		self.mc_1.currentView.btn_1:setVisible(false)
	end
end

--点击参战进入布阵界面
function ShareBossDetailView:clickBattle()
	local trid = self._data._id
	local tsec = self._data.sec
	local tags = FuncCommon.splitStringIntoTable(self._data.tagsStr)
	local attr = FuncShareBoss.getBuffAttrByBuffId(tostring(self._data.buffId))
	local levelId = FuncShareBoss.getLevelIdById(self._data.bossId)
	if self.canzhanCount < self.maxCountEveryBoss then
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
	else
		WindowControler:showTips(FuncTranslate._getErrorLanguage("#error540303"))
	end	
end

function ShareBossDetailView:enterBattle(params)
	local params = params.params
	local formation = params.formation
	local trid = params.params[FuncTeamFormation.formation.shareBoss].trid
	local tsec = params.params[FuncTeamFormation.formation.shareBoss].tsec
	ShareBossModel:setSelectedId(trid)
	if params.systemId == FuncTeamFormation.formation.shareBoss then
		local shareBossData = ShareBossModel:getBossDataById(trid)
		--如果选中进战斗的幻境已经过期 则关闭布阵界面
		if shareBossData and shareBossData.expireTime > TimeControler:getServerTime() then
			ShareBossServer:challengeShareBossList(formation, trid, tsec, c_func(self.doFormationCallBack, self))
		else
			WindowControler:showTips(GameConfig.getErrorLanguage("#error540304"))
			EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
			EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_DATA_CHANGED, {_id = trid})
		end
	end
end

function ShareBossDetailView:doFormationCallBack(event)
    if event.result then
        if event.result.data then
        	local serviceData = event.result.data.battleInfo
        	serviceData.battleLabel = GameVars.battleLabels.shareBossPve
	        local battleInfoData = BattleControler:turnServerDataToBattleInfo(serviceData)
	        EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
	        BattleControler:startBattleInfo(battleInfoData)
        end       
    end
end

--加载排行数据
function ShareBossDetailView:updateScrollView()
	-- 排行数据
	local rankDatas = self._data.totalDamages or {}

	local sortedRankDatas = {}
	for k, v in pairs(rankDatas) do
		table.insert(sortedRankDatas, v)
	end
	table.sort(sortedRankDatas, function (a, b)
		return a.damage > b.damage
	end)
	for i,v in ipairs(sortedRankDatas) do
		v.rank = i
	end

	self.mc_1.currentView.panel_1:setVisible(false)

	local createCellFunc = function (_rankData)
        local view = UIBaseDef:cloneOneView(self.mc_1.currentView.panel_1)        
		self:updateRankCellView(view, _rankData)
		return view
    end

    local reuseUpdateCellFunc = function (_rankData, view)
        self:updateRankCellView(view, _rankData)  
    end

	local _rankParmas = {
		{
			data = sortedRankDatas,	        
	        createFunc = createCellFunc,
	        offsetX = 10,
	        offsetY = 10,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -58, width = 512, height = 58},
	        updateCellFunc = reuseUpdateCellFunc,
		}
	}

	self.scrollView:styleFill(_rankParmas)
	self.scrollView:refreshCellView(1)
	-- self.scrollView:hideDragBar()
end

function ShareBossDetailView:updateRankCellView(_view, _rankData)
	local name = _rankData.name
	if name == "" then
		name = "少侠"
	end
	
	local damage = _rankData.damage
	local rank = _rankData.rank
	local bossId = self._data.bossId
	local rankRewards = FuncShareBoss.getRankRewardsById(tostring(bossId))
	local grade = 1
	local count = 1
	
	if #(tostring(damage)) > 8 then
		damage = math.floor(damage / 10000).." 万"
	end

	if tostring(_rankData.rid) == tostring(UserModel:rid()) then
		_view.rich_name:setString("<color = c52a00>"..name.."<->")
		_view.rich_pm:setString("<color = c52a00>"..damage.."<->")
		_view.panel_1:setVisible(true)
	else
		_view.rich_name:setString("<color = 7d563c>"..name.."<->")
		_view.rich_pm:setString("<color = 0d8a0d>"..damage.."<->")
		_view.panel_1:setVisible(false)
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

	--当参战达到只能获取侠义值状态时 就不显示排行奖励了
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

function ShareBossDetailView:deleteMe()
	-- TODO

	ShareBossDetailView.super.deleteMe(self);
end

return ShareBossDetailView;
