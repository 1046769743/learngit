local ArenaMainView = class("ArenaMainView", UIBase)

function ArenaMainView:ctor(winName)
    ArenaMainView.super.ctor(self, winName)
end

function ArenaMainView:loadUIComplete()
	-- 初始化需要隐藏的组件
	self.initHideComp = 
	{	self.btn_shop, self.btn_huifang,self.btn_reward,self.btn_mb,
		self.panel_1,self.btn_shuaxin
	}

	for k, v in pairs(self.initHideComp) do
		v:setVisible(false)
	end

	-- 隐藏商店红点
	self.btn_shop:getUpPanel().panel_red:setVisible(false)
	-- 隐藏气泡
	self.panel_qipao1:setVisible(false)
	self.panel_qipao2:setVisible(false)
	self.panel_qipao3:setVisible(false)

	self:loadkQuestUI(DailyQuestModel:getquestId());
	
	self._anim_show_left_btns = true
	-- self.UI_refresh_cd:setVisible(false)
	self.UI_topitem:visible(false)
	self.UI_commonitem:visible(false)
	-- self.UI_player:visible(false)
	self.UI_player_talk:visible(false)
	-- self.btn_jf:setVisible(false)
	-- self.btn_shuoming:setVisible(false)
	-- self.txt_power:setVisible(false)
	-- self.UI_add_count:setVisible(false)
	-- self.panel_qipao:setVisible(false)
	self.btn_bzjc:setVisible(false)
	-- self.panel_power:setVisible(false)
	-- self.btn_fangshouzhenrong:setVisible(false)
	-- self.panel_zuo:setVisible(false)
	-- self.panel_you:setVisible(false)
--	self.btn_shuaxin:visible(false)

	self.pvp_list_inited = false
	self.talk_has_began = false
	self:adjustScrollRect()
	self:alignUIItems()
	self:registerEvent()
--	self:hideRightSideBtns()

	--初始化显示背景
	self:initPvpList({})

	self:showCloud()
	self:refreshMatch()
	-- self:checkCdTime()
	
	--检查小红点
	PVPModel:checkNewReport()
	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self),0)
	self:updatePowerTxt()
	PVPModel:setRefreshType(false)
	self:updateIntegralBubble()
	self.buffId = PVPModel:getBuffIdByServerTime()
end

-- 打开膜拜界面
function ArenaMainView:showHornorView(worship)
	if worship then
		WindowControler:showWindow("HonorView", worship)
	else
		echoWarn("\n\n——————膜拜对象为机器人——————")
	end
end

function ArenaMainView:initMoBaiBtn()
	local honorData = PVPModel:getHonorData()
	--=如果登仙台第一数据存在 且 不是机器人 就显示膜拜按钮 否则隐藏
	if honorData and honorData.type ~= 2 then
		self.btn_mb:setVisible(true)
	else
		self.btn_mb:setVisible(false)
	end

	self.btn_mb:setTap(c_func(self.showHornorView, self, honorData))
end

function ArenaMainView:honorPlayerUpdate()
	self:initMoBaiBtn()
	self:updateHonorRedPoint()
end

-- 初始化气泡
function ArenaMainView:initBubbles()
	self.curBubbleIndex = 0
	self.curBubbleView = nil

	self.maxBubbleNum = 3

	self.frameCount = 0
	-- 间隔3秒显示一个气泡
	self.intervalFrame = 3 * GameVars.GAMEFRAMERATE
	-- 每个气泡显示8秒
	self.dispayFrame = 8 * GameVars.GAMEFRAMERATE
end

function ArenaMainView:showBubble()
	if self.curBubbleIndex == 2 and self.needHideShopBubble then
		self["panel_qipao" .. (self.curBubbleIndex + 1)]:setVisible(false)
		self.curBubbleIndex = 0
	end

	if self.curBubbleIndex >= self.maxBubbleNum then
		self.curBubbleIndex = 0
	end

	self.curBubbleIndex = self.curBubbleIndex + 1
	self.curBubbleView = self["panel_qipao" .. self.curBubbleIndex]

	self.curBubbleView:setScale(0)
	self.curBubbleView:setVisible(true)

	local showAction = act.sequence(act.scaleto(0.2, 1),nil)
	self.curBubbleView:stopAllActions()
	self.curBubbleView:runAction(showAction)
end

function ArenaMainView:hideBubble()
	local hideAction = act.sequence(act.scaleto(0.2, 0),nil)
	self.curBubbleView:runAction(hideAction)
end

function ArenaMainView:updateFrameForBublle()
	self.frameCount = self.frameCount + 1
	if self.frameCount == self.intervalFrame then
		self:showBubble()
	elseif self.frameCount == (self.intervalFrame + self.dispayFrame) then
		self.frameCount = 0
		self:hideBubble()
	end
end

function ArenaMainView:hideRightSideBtns()
	local btns = {self.btn_shop, self.btn_huifang, self.btn_shuoming, self.btn_shuaxin}
	for i,btn in pairs(btns) do
		btn:visible(false)
	end
end

function ArenaMainView:showCloud()
	self.bigCloudAnim = self:createUIArmature("UI_arena","UI_arena_yunceng", self.ctn_big_cloud, false, GameVars.emptyFunc)
	self.bigCloudAnim:gotoAndPause(1)
end

function ArenaMainView:animShowButtons()
	if not self._anim_show_left_btns then
		return
	end

	-- 初始化气泡逻辑
	self:initBubbles()
    --暂时屏蔽掉动画
    -- self._anim_show_left_btns = false
    -- if true then return end
    ----
	for k, v in pairs(self.initHideComp) do
		if v == self.btn_mb then
			self:initMoBaiBtn()
		else
			v:setVisible(true)
		end
	end

	-- local posInfo = {
	-- 	{x=-33, y=34}, 
	-- 	{x=-33, y=43}, 
	-- 	{x=-33, y=55}, 
	-- }
	-- local anim = self:createUIArmature("UI_arena", "UI_arena_btns", self.ctn_btns, false, GameVars.emptyFunc)
	-- anim:gotoAndPause(1)
	-- for i,btn in ipairs(btns) do
	-- 	local pos = posInfo[i]
	-- 	btn:pos(pos.x, pos.y)
	-- 	FuncArmature.changeBoneDisplay(anim, "bone"..i, btn)
	-- 	btn:visible(true)
	-- end
	-- local onAllBtnShow = function()
	-- 	self._anim_show_left_btns = false
	-- end
	-- anim:registerFrameEventCallFunc(20, 1, c_func(onAllBtnShow))
	-- anim:startPlay(false)
	-- self.btn_bzjc:setVisible(true)
	-- self.btn_shop:setVisible(true)
	-- self.btn_huifang:setVisible(true)
	-- self.btn_jf:setVisible(true)
	-- self.btn_shuoming:setVisible(true)

	-- self.panel_power:setVisible(true)
	-- self.btn_fangshouzhenrong:setVisible(true)
	-- self.panel_zuo:setVisible(true)
	-- self.panel_you:setVisible(true)
	-- self.txt_power:setVisible(true)
	-- self.UI_add_count:setVisible(true)
	-- self.panel_qipao:setVisible(true)	
	self:updateShopBubble()
	-- self.panel_qipao:setScale(0)
	--[[
	local act_sequence = act.sequence(
                    act.scaleto(0.3, 1),
                    act.delaytime(2),
                    act.scaleto(0.2, 0),
                    act.delaytime(2)
                )]]
	-- self.panel_qipao:runAction(act._repeat(act_sequence))

	self:updateBuffBtn()
	self._anim_show_left_btns = false
end


--初始化玩家自己的信息
function ArenaMainView:updatePlayerUI(showAnim)
	self.userRank = PVPModel:getUserRank()
	local myView = self.panel_1
	-- 我的排名
	myView.txt_1:setString(GameConfig.getLanguageWithSwap("tid_pvp_tips_1007", self.userRank))
	-- 进攻战斗力
	local ability = UserModel:getPvpAbility(FuncTeamFormation.formation.pvp_attack)
	myView.txt_power:setString(GameConfig.getLanguageWithSwap("tid_pvp_tips_1001",ability))
	
	-- 头像
    local ctn =  self.panel_1.panel_tx.ctn_2
    UserHeadModel:setPlayerHeadAndFrame(ctn,UserModel:avatar(),UserModel:head(),UserModel:frame())

	-- TODO
	--[[
	self.userRank = PVPModel:getUserRank()
	self.UI_player:visible(true)
	local info = FuncPvp.getPlayerRankInfo(self.userRank)
	self.UI_player:setPlayerInfo(info)
	if self.userRank < FuncPvp.SHOW_SELF_MIN_RANK  then
		self.UI_player:showTopThreeMark()
		self.UI_player:setVisible(false);
	else
		self.UI_player:updateUI(showAnim)
	end
	]]
end

function ArenaMainView:adjustScrollRect()
	--禁止回弹
	--self.scroll_arenalist:setBounceable(false)
	local viewRect = self.scroll_arenalist:getViewRect()
	viewRect.height = viewRect.height + (GameVars.height - GameVars.gameResHeight)
	viewRect.y = - viewRect.height
	self.originScrollViewRect = table.deepCopy(viewRect)
	--更新viewRect 的时候，要注意设置更新viewrect的y值
	viewRect.y = -viewRect.height
	self.scroll_arenalist_view_rect = viewRect
	self.scroll_arenalist:setBounceDistance(184*1.5)
	self.scroll_arenalist:setCanAutoScroll(false)
	self.scroll_arenalist:updateViewRect(viewRect)
end


function ArenaMainView:alignUIItems()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.scroll_arenalist, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_wen, UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_player, UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_add_count, UIAlignTypes.RightBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_refresh_cd, UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_huifang, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.ctn_btns, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_shop, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_shuoming, UIAlignTypes.Left)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_jf, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_shuaxin, UIAlignTypes.RightBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_power, UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_qipao, UIAlignTypes.LeftBottom)	
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_bzjc, UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_fangshouzhenrong, UIAlignTypes.RightBottom)	
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_zuo, UIAlignTypes.LeftBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_you, UIAlignTypes.RightBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_power, UIAlignTypes.RightBottom)

	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_reward, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_mb, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_huifang, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_1, UIAlignTypes.Right)

	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_qipao1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_qipao2, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_qipao3, UIAlignTypes.Left)
end

function ArenaMainView:frameUpdate()
	self:updateRefreshBtn()
	self:adjustTalkViews()
	-- 膜拜红点状态
    self:updateHonorRedPoint()
	if not self._anim_show_left_btns then
		self:updateFrameForBublle()
	end
end

function ArenaMainView:initPvpList(data)
	-- echo("竞技场数据======")
	-- dump(data)

	local topItems = data.topThree or {2}
	local commonItems = data.opponents or {1}
	local userRank = data.userRank

	local createTopItem = function(itemInfo)
		local view = UIBaseDef:cloneOneView(self.UI_topitem)
		view:setArenaList(self.scroll_arenalist)
		self.topPvpView = view
		return view
	end

	local createCommonItem = function(itemInfo)
		local view = UIBaseDef:cloneOneView(self.UI_commonitem)
		view:setArenaList(self.scroll_arenalist)
		self.commonPvpView = view
		return view
	end
	self.topViewHeight = 695
	self.bottomViewHeight = 920
	local scrollTopItemParam = {
		data = topItems,
		createFunc = createTopItem,
		perNums =1,
		perFrame=1, --分帧
		offsetX = 155,		--TODO因flash制作问题临时修改
		offsetY = 40,
		widthGap = 0,
		heightGap = 0,
		itemRect = {x=0,y= -self.topViewHeight, width = 670,height = self.topViewHeight},
	}
	local scrollCommonItemParam = {
		data = commonItems,
		createFunc = createCommonItem,
		perNums =1,
		perFrame=1, --分帧
		offsetX = 155,
		offsetY = 20,
		widthGap = 0,
		heightGap = 0,
		itemRect = {x=0,y= -self.bottomViewHeight, width = 670,height = self.bottomViewHeight},
	}

	local scroll_param = {scrollTopItemParam, scrollCommonItemParam}
	self.scroll_arenalist:hideDragBar()
    self.scroll_arenalist:cancleCacheView();
	self.scroll_arenalist:styleFill(scroll_param)
	self.pvp_list_inited = true
	self:updateScrollBehavior()
end

function ArenaMainView:makeWinScrollAction()
	if not PVPModel:isLastFightWin() then
		return
	end
	local viewRect = table.deepCopy(self.originScrollViewRect)
	local delta = 184*4
	viewRect.height = viewRect.height + delta
	viewRect.y = - viewRect.height
	self.scroll_arenalist:updateViewRect(viewRect)
	local distance = 184--184--*1.5 --+ 80
	self.scroll_arenalist:runAction(act.moveby(0, 0, distance))
    if(self._playerViews~=nil)then
		for _,playerView in pairs(self._playerViews) do
			playerView:visible(false)
		end
    end
	
	local restoreScrollRect = function()
        if(self._playerViews ~=nil)then
		     for _,playerView in pairs(self._playerViews) do
                --如果是低于 10001的排名,肯定是要隐藏的
                playerView:removeOriginPlayer();
			    playerView:visible(true)
		     end
        end
		self.scroll_arenalist:updateViewRect(self.originScrollViewRect)	
	end
	self.scroll_arenalist:runAction(act.sequence(act.moveby(0.5, 0, -distance), act.callfunc(restoreScrollRect)))
end

function ArenaMainView:registerEvent()
	ArenaMainView.super.registerEvent()

	self.btn_huifang:setTap(c_func(self.press_btn_huifang, self))
	self.btn_wen:setTap(c_func(self.press_btn_shuoming, self))
    self.btn_back:setTap(c_func(self.press_btn_back, self))
    --排名兑换将
    -- self.btn_shuoming:setTap(c_func(self.clickButtonRankExchg,self))
    --积分奖励
    -- self.btn_jf:setTap(c_func(self.clickButtonScore,self))
	self.btn_shop:setTap(c_func(self.press_btn_shop, self))
	-- 刷新，更换对手
	self.btn_shuaxin:setTap(c_func(self.refreshMatch, self, true))
	self.btn_bzjc:setTouchedFunc(c_func(self.showBuffView, self))
	-- 防守阵容
	self.panel_1.btn_fangshouzhenrong:setTap(c_func(self.clickButtonDefence, self))
	--self.btn_shuaxin:setTouchSwallowEnabled(true)
	-- 奖励
	self.btn_reward:setTap(c_func(self.showRewardView,self))
	-- 膜拜
	-- self.btn_mb:setTap(c_func(self.showHornorView,self))

    ---- 刷新匹配
    ---- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)

    -- TODO 需要重构消息监听 by ZhangYanguang
	-- EventControler:addEventListener(PvpEvent.PVPEVENT_CLEAR_CHALLENGE_CD_OK, self.onClearCdEnd, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_REPORT_RESULT_OK, self.onReportResultOk, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_PVP_FIGHT_EXCEPTION, self.onFightException, self)
    --冷却时间CD事件
	local pvpCdDownLevelTimeEvent = CdModel:getCdTimeEventKeyByCdId(CdModel.CD_ID.CD_ID_PVP_UP_LEVEL)
	-- EventControler:addEventListener(pvpCdDownLevelTimeEvent, self.onChallengeCdOver, self)
--	local pvpCdUpLevelTimeEvent = CdModel:getCdTimeEventKeyByCdId(CdModel.CD_ID.CD_ID_PVP_UP_LEVEL)
--	EventControler:addEventListener(pvpCdUpLevelTimeEvent, self.onChallengeCdOver, self)

	EventControler:addEventListener(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD, self.updateRefreshBtn, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK, self.onBuyPvpCountOk, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_PVP_REPORT_RED_POINT, self.checkReportRedPoint, self)
--	EventControler:addEventListener(PvpEvent.PVPEVENT_RECORD_NEW_TITLE_OK, self.onRecordNewTitle, self)
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE, self.onBattleClose, self)
    EventControler:addEventListener("notify_pvp_new_fight_resport_1116", self.refreshMatch, self)
    --排名兑换
    EventControler:addEventListener(PvpEvent.RANK_EXCHANGE_CHANGED_EVENT,self.notifyRankXchgChanged,self)
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_CHANGED_EVENT,self.notifyRankXchgChanged,self)
    EventControler:addEventListener(PvpEvent.PVP_RANK_CHANGED,self.notifyRankXchgChanged,self)
    EventControler:addEventListener(UserEvent.USEREVENT_PVP_COIN_CHANGE,self.notifyRankXchgChanged,self)
    EventControler:addEventListener(PvpEvent.PVP_BATTLE_WIN,self.notifyRankXchgChanged,self)

    --积分兑换
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_CHANGED_EVENT,self.notifyScoreRewardChanged,self)
    -- 战斗胜利
    EventControler:addEventListener(PvpEvent.PVP_BATTLE_WIN,self.notifyScoreRewardChanged,self)
    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE, self.notifyScoreRewardChanged, self)
    EventControler:addEventListener(PvpEvent.PVP_RANK_REWARD_EVENT, self.notifyScoreRewardChanged, self)
    
    EventControler:addEventListener(PvpEvent.CHALLENGE_TIMES_CHANGED_EVENT, self.updateShopBubble, self)
    --需要注册一个从后台切换的监听函数
    -- local _cdListener = cc.EventListenerCustom:create(SystemEvent.SYSTEMEVENT_APP_ENTER_FOREGROUND,
    --                             c_func(self.checkCdTime,self));

    -- cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(_cdListener, 10)
    -- self.__cdListener=_cdListener;
    self:notifyScoreRewardChanged()
    self:notifyRankXchgChanged()

    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW,
        self.pvpBattleBegin, self);
    EventControler:addEventListener(TeamFormationEvent.PVP_ATTACK_CHANGED, self.updatePowerTxt, self)
    EventControler:addEventListener(TeamFormationEvent.PVP_DEFENCE_CHANGED, self.updatePowerTxt, self)
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_REFRESH_EVENT, self.refreshScoreAndBuffButtons, self)

    EventControler:addEventListener(HomeEvent.REFRESH_HONOR_EVENT, self.honorPlayerUpdate, self)
end

--弹出防守阵容UI
function ArenaMainView:clickButtonDefence()
    --发送协议,获取玩家的信息
 --   PVPServer:requestPlayerDetail(self.info.rid,c_func(self.displayPlayerEvent,self))
--    self:displayPlayerEvent()
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pvp_defend)
end

function ArenaMainView:showBuffView()
	WindowControler:showWindow("ArenaBuffView", self.buffId)
end

function ArenaMainView:refreshScoreAndBuffButtons()
	self.buffId = PVPModel:getBuffIdByServerTime()
	self:updateBuffBtn()
	self:updateIntegralBubble()
end

function ArenaMainView:updatePowerTxt()
	local ability = UserModel:getPvpAbility(FuncTeamFormation.formation.pvp_attack)
	self.panel_1.txt_power:setString(GameConfig.getLanguageWithSwap("tid_pvp_tips_1001", ability))
	-- self.panel_power.UI_1:setPower(tonumber(ability))
end

function ArenaMainView:pvpBattleBegin(event)
	-- dump(event, "-----pvpBattleBegin-event---");


	--LogsControler:writeDumpToFile(event,8,8)
	

    local params = event.params;
    local systemId = params.systemId;

	echo("-------pvpBattleBegin-----", tostring(systemId));

    if systemId == FuncTeamFormation.formation.pvp_defend or 
            systemId == FuncTeamFormation.formation.pvp_attack then 

        FuncPvp.onChallengePlayerEvent(params.params,event.params.formation,
            c_func(self.doBattle, self, params.params));
    end

end

function ArenaMainView:doBattle(params, _event)
    EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE);

    if _event.result == nil then
        echo("竞技场战斗 服务器返回没有result数据，不进战斗------")
		if _event.error then
			--战斗异常1.对手正在战斗 2. 对手排名变化 3 玩家排名变化			
	        EventControler:dispatchEvent(PvpEvent.PVPEVENT_PVP_FIGHT_EXCEPTION)
	    end
        return
    end 

    PVPModel:setLastFightResult(_event.result.data.report.result);

    -- dump(params, "\n\nparams")
    -- dump(_event.result, "----_event.result-----");
    
    local _battleInfo  = _event.result.data
    if not FuncPvp.processChallengeErrorEvent(_event) then
        -- WindowControler:showBattleWindow("ArenaBattleLoading", params)

        local backData = _event.result.data
        
        if backData.result and backData.result == 1 then
        	PVPModel:setForceRefresh(true)
        end

        local info = {}
        info.battleId = backData.report.battleId
        info.battleLabel = GameVars.battleLabels.pvp 
        info.battleUsers = backData.report.battleUsers
        info.battleParams = backData.report.battleParams
        info.randomSeed = backData.report.randomSeed

        if not info.battleUsers[1].rank or not info.battleUsers[2].rank then
        	info.battleUsers[1].rank = self.userRank
        	info.battleUsers[2].rank = params.rank 
        end

        

        if not info.battleUsers[2].avatar then
        	info.battleUsers[2].avatar = params.avatar
        	info.battleUsers[2].name = params.name
        end


        info.lastHistoryTopRank = PVPModel:getLastHistoryRank()
        
        PVPModel:updateData(_battleInfo)
        info.historyTopRank = PVPModel:getLastHistoryRank()
        info.historyRank = self.userRank
        if  backData.historyRank and backData.userRank then
            info.userRank  = backData.userRank    
        end

        --LogsControler:writeDumpToFile(info, 8, 8)
		PVPModel:setCurrentPvpBattleInfo(backData)
        BattleControler:startBattleInfo(info)
    end
end

--//退出时删除监听器
function ArenaMainView:deleteMe()
--//删除监听器  
    -- cc.Director:getInstance():getEventDispatcher():removeEventListener(self.__cdListener);
    -- self.__cdListener=nil;
    ArenaMainView.super.deleteMe(self);
end
--战斗关闭,重新回到竞技场主界面
function ArenaMainView:onBattleClose()
	--胜利后进行柱子往下滚动的操作
	if BattleControler:checkIsPVP() then 
		local curPvpBattleInfo = PVPModel:getCurrentPvpBattleInfo()
	
		if curPvpBattleInfo.rewards and table.length(curPvpBattleInfo.rewards) > 0 then
			self.hasReward = true
		else
			self.hasReward = false
		end

		local showRewards = function ()
			if self.hasReward == true then
				-- dump(curPvpBattleInfo.rewards, "\n\ncurPvpBattleInfo.peakRewards===")
				-- WindowControler:showTips(GameConfig.getLanguage("pvp_mail_reward_tips_1008"), 2)
				local tipStr = GameConfig.getLanguage("#tid_pvp_tips_2003")
				WindowControler:showWindow("RewardSmallBgView", curPvpBattleInfo.rewards, nil, tipStr)
			end	
		end
		self:makeWinScrollAction()
		self:delayCall(showRewards, 1)
	end
end

function ArenaMainView:onRecordNewTitle()
--pvp称号功能去掉
--	local latestTitleId = PVPModel:getLatestAchievedTitle()
--	if latestTitleId then
--		WindowControler:showWindow("ArenaTitleAchieveView", latestTitleId)
--	end
end

function ArenaMainView:checkReportRedPoint(event)
	local isShow = event.params
	self.btn_huifang:getUpPanel().panel_red:visible(isShow)
	EventControler:dispatchEvent(PvpEvent.PVP_RED_POINT_EVENT);
end
--积分奖励红点
function ArenaMainView:notifyScoreRewardChanged(_param)
    self:updateJiangLiRedPoint()
    self:updateIntegralBubble()
    EventControler:dispatchEvent(PvpEvent.PVP_RED_POINT_EVENT);
end

--[[
	更新奖励按钮红点状态
	1.奖励
	2.排名
	3.兑换
]]
-- 更新奖励按钮红点状态
function ArenaMainView:updateJiangLiRedPoint()
	local isShow = PVPModel:isScoreRewardRedPointShow()
		 or PVPModel:isRankRedPointShow()
		 or PVPModel:isRankRewardRedPointShow()

	local panelRed = self.btn_reward:getUpPanel().panel_red
	panelRed:setVisible(isShow)
end

--[[
	更新膜拜按钮红点状态
]]
function ArenaMainView:updateHonorRedPoint()
	-- TODO
	local count = CountModel:getHonorCountTime()
	local panelRed = self.btn_mb:getUpPanel().panel_red
	if count == 0 then
		panelRed:setVisible(true)
	else
		panelRed:setVisible(false)
	end
	
end

--排名奖励事件
function ArenaMainView:notifyRankXchgChanged(_param)
    -- local isRankPointShow = PVPModel:isRankRedPointShow();
    -- self.btn_shuoming:getUpPanel().panel_red:setVisible(isRankPointShow);
    self:updateJiangLiRedPoint()
    self:updateRankExchangeBubble()
    EventControler:dispatchEvent(PvpEvent.PVP_RED_POINT_EVENT);
end

function ArenaMainView:onBuyPvpCountOk()
	PVPModel:checkNewReport()
end

--战斗异常1.对手正在战斗 2. 对手排名变化 3 玩家排名变化
function ArenaMainView:onFightException()
	self:refreshMatch()
end

-- function ArenaMainView:onClearCdEnd(event)
-- 	PVPModel:checkNewReport()
-- 	self:checkCdTime()
-- end

-- function ArenaMainView:onChallengeCdOver(event)
-- 	PVPModel:checkNewReport()
-- 	self:checkCdTime()
-- end

--根据排名情况修改滚动视图行为
--前三名的时候就不滚动了
function ArenaMainView:updateScrollBehavior()

	if not self.pvp_list_inited then
		self.scroll_arenalist:gotoTargetPos(1, 2, 2)
		return
	end
	local userRank =  PVPModel:getUserRank()

	if userRank <= FuncPvp.SHOW_SELF_MIN_RANK then
		local refreshType = PVPModel:getRefreshType()
		if refreshType then
			self.scroll_arenalist:gotoTargetPos(1, 2, 2)
		else
			self.scroll_arenalist:gotoTargetPos(1, 1, 2)
		end
		
		-- 禁止滑动滚动条
		-- self.scroll_arenalist:setCanScroll(false)
		-- self.scroll_arenalist:onScroll(nil)
		self.scroll_arenalist:setCanScroll(true)
		self.scroll_arenalist:onScroll(c_func(self.onArenaListScroll, self))
	else
		self.scroll_arenalist:setCanScroll(true)
		self.scroll_arenalist:onScroll(c_func(self.onArenaListScroll, self))
        self.scroll_arenalist:gotoTargetPos(1, 2, 2)
	end
end

--每一帧去检查
function ArenaMainView:adjustTalkViews()
	local x, y = self.scroll_arenalist:getCurrentPos()
	if not self._last_pos_y then
		self._last_pos_y = y
	end
	if self._playerViews then
		local delta = y - self._last_pos_y
		for _,playerView in pairs(self._playerViews) do
			playerView:adjustTalkViewPos(delta)
		end
		self._last_pos_y = y
	end
end

function ArenaMainView:onArenaListScroll(event)
	local y = event.y and math.floor(event.y) or 0
	if event.name == self.scroll_arenalist.EVENT_BEGAN then
		local x, y = self.scroll_arenalist:getCurrentPos()
		self._scroll_began_y = math.floor(y)
		self._last_pos_y = y
	end

	if event.name == self.scroll_arenalist.EVENT_SCROLLEND then
		local curx, cury = self.scroll_arenalist:getCurrentPos()
		local viewRect = self.scroll_arenalist_view_rect 
		if self._scroll_began_y < viewRect.height then 
			if cury > viewRect.height/3 then
				self.scroll_arenalist:gotoTargetPos(1,2,2, 0.2)
			end
		else
			if cury < (self.topViewHeight + self.bottomViewHeight - viewRect.height) - viewRect.height/4 then
				self.scroll_arenalist:gotoTargetPos(1,1,2, 0.2)
			end
		end
	end
end

function ArenaMainView:onReportResultOk(event)
	-- self:checkCdTime()
	local serverData = event.params
	local data = serverData.result.data
	if data.result == Fight.result_win then
		--胜利
		PVPModel:setUserRank(data.userRank)
		PVPModel:cacheRankList(data)
		self:updatePlayerUI()
	elseif data.result == Fight.result_lose then
		--失败

	end
end

-- function ArenaMainView:checkCdTime()
-- 	local left = FuncPvp.getPvpCdLeftTime()
-- 	local show = left > 0
-- 	self.UI_refresh_cd:updateUI()
-- 	self.UI_refresh_cd:visible(show)
--     if(not show)then--//检查最上层的UI是否是 ArenaClearChallengeCdPop
--        local  topWin=WindowControler:getCurrentWindowView();
--        if(topWin and topWin.windowName=="ArenaClearChallengeCdPop")then
--            --WindowControler:closeWindow("ArenaClearChallengeCdPop");
--            topWin:startHide();
--        end
--     end
-- end

function ArenaMainView:refreshMatch(manul)
	if manul and PVPModel:getUserRank() < FuncPvp.REFRESH_BTN_SHOW_MIN_LEVEL then
		WindowControler:showTips(GameConfig.getLanguage("#tid_pvp_des008"))
		return
	end

	self.btn_shuaxin:setTouchEnabled(false)
	if manul then
		local left = TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD)
		if left > 0 then 
			WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1045"))
			return 
		end
		--记录刷新时间,防止过快频繁点击刷新
		if PVPModel:recordManulRefresh() then
			PVPServer:refreshPVP(c_func(self.onRefreshMatch,self))
		else
			TimeControler:startOneCd(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD, FuncPvp.REFRESH_TO_FAST_CD)
		end
	else
		if PVPModel:getForceRefresh() == true then
			PVPServer:refreshPVP(c_func(self.onRefreshMatch,self))
			PVPModel:setForceRefresh(false)
		else
			--如果还有点击过快cd，加载缓存数据
			local left = TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD)
			if left > 0 then
				self:onRefreshMatch({result = {data = PVPModel:getCacheRankList()}})
			else
				PVPServer:refreshPVP(c_func(self.onRefreshMatch,self))
			end
		end
		
	end
end

function ArenaMainView:updateRefreshBtn()
	if self._anim_show_left_btns then
		return 
	end
	-- --前10名不显示换一批按钮
	-- if PVPModel:getUserRank() < FuncPvp.REFRESH_BTN_SHOW_MIN_LEVEL then
	-- 	self.btn_shuaxin:visible(false)
	-- 	return
	-- else
	-- 	self.btn_shuaxin:visible(true)
	-- end
	-- local groupIndex, itemIndex = self.scroll_arenalist:getGroupPos(1)
	-- if groupIndex == 1 then
	-- 	self.btn_shuaxin:visible(false)
	-- 	return
	-- end
	local left = TimeControler:getCdLeftime(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD)

	if left > 0 then
		-- self.btn_shuaxin:setBtnStr(string.format("00:%02d", left))
		FilterTools.setGrayFilter(self.btn_shuaxin)
	else
		-- self.btn_shuaxin:setBtnStr(GameConfig.getLanguage("tid_pvp_1046"))
		FilterTools.clearFilter(self.btn_shuaxin)
	end
end

function ArenaMainView:onRefreshMatch(event)
    --对
	if self.bigCloudAnim ~= nil then
		self.bigCloudAnim:doByLastFrame(true, true, c_func(self.onCloudDisappear, self, event, true))
		self.bigCloudAnim:startPlay(false)
		self.bigCloudAnim = nil
	else
		self:onCloudDisappear(event, false)
	end
end
function ArenaMainView:processRobot(_data)
    local _commItem = _data.opponents
    for _key,_value in pairs(_commItem) do
        _value.rid_back =_value.rid --留待以后的发送挑战对手协议时使用
        if _value.type == FuncPvp.PLAYER_TYPE_ROBOT then--如果是机器人
            _value.rid = FuncPvp.genRobotRid(_value.rid)
        end
    end
    local _topItem = _data.topThree
    for _key,_value in pairs(_topItem) do
        _value.rid_back =_value.rid --留待以后的发送挑战对手协议时使用
        if _value.type == FuncPvp.PLAYER_TYPE_ROBOT then--如果是机器人
            _value.rid = FuncPvp.genRobotRid(_value.rid)
        end
    end
end
function ArenaMainView:onCloudDisappear(event, playCloud)
	self.btn_shuaxin:setVisible(true)
	self:animShowButtons()
    if event.result ~= nil then
        --对数据进行预处理
        local data = event.result.data
        self:processRobot(data)
		PVPModel:setUserRank(data.userRank)
		PVPModel:cacheRankList(data)
        if not self.pvp_list_inited then
			self:initPvpList({})
		else
			self:updatePvpList()
		end
		self:updatePlayerUI(playCloud)
		self.btn_shuaxin:setTouchEnabled(true)
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_pvp_007")) 
    end
end


function ArenaMainView:updatePvpList()
	local sortByRank = function(a, b)
		return tonumber(a.rank)<tonumber(b.rank)
	end

	local data = PVPModel:getCacheRankList()
	-- TODO 暂时关闭该log
	-- dump(data, "------ArenaMainView:updatePvpList 不要关闭我 测竞技场同名bug------");

	local topThree = data.topThree or {}
	local opponents = data.opponents or {}
	table.sort(topThree, sortByRank)
	table.sort(opponents, sortByRank)
	local players = {}
	for i=1,3 do
		local info = topThree[i]
		if info then
			players[i] = info
		else
			players[i] = -1
		end
	end
	for i=1,4 do -- 修改数据的数目
		local info = opponents[i]
		if info then
			players[i+3] = info
		else
			players[i+3] = -1
		end
	end
	local keys = {4,5,6,7,1,2,3}

	local count = 1
	self._playerViews = {}
	for _, i in ipairs(keys) do
		local index = i
		local view = self.commonPvpView
		local info = players[i]
		if i>3 then
			index = i-3
		else
			view = self.topPvpView
		end
		local playerView
		if type(info) ~= "table" then --此时玩家可能是第一次进入竞技场,由于排名最低,所以需要隐藏最后的一个
			playerView = view:updateOnePlayer(index, info, self)
			self._playerViews[index] = playerView 
		else
			local updateOnePlayer = function()
				playerView = view:updateOnePlayer(index, info, self)
				self._playerViews[i] = playerView
			end
			self:delayCall(c_func(updateOnePlayer), 0.3)--原来的是count*0.3
			count = count + 1
		end
	end
	self:updateScrollBehavior()
	PVPModel:setRefreshType(false)
	--只执行一次
	if not self.talk_has_began then
		self:delayCall(c_func(self.beganShowTalk, self), 2)
		self.talk_has_began = true
	end
end

function ArenaMainView:beganShowTalk()
	local groupIndex, itemIndex = self.scroll_arenalist:getGroupPos(1)
	local index_keys = {1, 2, 3 }
	if groupIndex == 2 then
		index_keys = {4, 5, 6}
	end
	if self._last_talk_player then
		self._last_talk_player:hideTalk()
	end
	local rand_index = RandomControl.getOneRandomInt(4, 1)
	local key = index_keys[rand_index]
	local playerView = self._playerViews[key]
	if playerView then
		self._last_talk_player = playerView
		playerView:showRandomTalk()
	end
	self:delayCall(c_func(self.beganShowTalk, self), 5)
end

-- 刷新一批
function ArenaMainView:freshMatch()
    self:refreshMatch()
end
--积分奖励
function ArenaMainView:clickButtonScore()
    WindowControler:showWindow("ArenaScoreRewardView")
end
-- 打开规则说明界面
function ArenaMainView:press_btn_shuoming()
    WindowControler:showWindow("ArenaRulesView")
end
--弹出排名兑换奖励
function ArenaMainView:clickButtonRankExchg()
    WindowControler:showWindow("ArenaRankExchangeView")
end
-- 打开战斗回放界面
function ArenaMainView:press_btn_huifang()
	--清空战报提示
	PVPModel:clearCurrentFightReports()
	PVPModel:checkNewReport()
--	WindowControler:showWindow("ArenaBattlePlayBackView")
    PVPServer:pullBattleRecord(c_func(self.onEventHostoryBattle,self))
end
--获取战报返回
function ArenaMainView:onEventHostoryBattle(_event)
    WindowControler:showWindow("ArenaBattlePlayBackView",_event.result.data)
end
-- 打开商店界面
function ArenaMainView:press_btn_shop()
    WindowControler:showWindow("ShopView", FuncShop.SHOP_TYPES.PVP_SHOP)
end

-- 返回
function ArenaMainView:press_btn_back()
    self:startHide()
end

-- 打开奖励界面
function ArenaMainView:showRewardView()
	-- WindowControler:showTips("打开奖励")
	-- ArenaRewardMainView
	-- ArenaRankExchangeView
	-- ArenaRewardScoreView
	WindowControler:showWindow("ArenaRewardMainView")
end

-- 更新积分气泡信息
function ArenaMainView:updateIntegralBubble()
	-- 最大挑战次数
	local maxTimes = 10

	local jf_panel = self.panel_qipao1
	local challenge_count = CountModel:getPVPChallengeCount()
	local count_show = 0
	local nextCount = challenge_count
	local reward_display = nil
	local isShowRedPoint, canGetNum = PVPModel:isScoreRewardRedPointShow()
	if challenge_count < maxTimes then	
		count_show = nextCount + 1
		reward_display = FuncPvp.getIntegralRewardDisplayByCount(nextCount + 1)	
	else
		nextCount = maxTimes
		count_show = nextCount
		reward_display = FuncPvp.getIntegralRewardDisplayByCount(nextCount)
	end
	local reward_str = {reward = reward_display[1]}

	if not isShowRedPoint and challenge_count >= maxTimes then
		jf_panel.mc_1:showFrame(2)
	else
		jf_panel.mc_1:showFrame(1)
		if canGetNum then
			jf_panel.mc_1.currentView.panel_shu:setVisible(true)
			jf_panel.mc_1.currentView.panel_shu.txt_lvl:setString(canGetNum)
		else
			jf_panel.mc_1.currentView.panel_shu:setVisible(false)
		end		
	end
	
	
	jf_panel.mc_1.currentView.UI_1:setResItemData(reward_str)
    jf_panel.mc_1.currentView.UI_1:showResItemName(false)
    
    if challenge_count < count_show then
    	count_show = "<color = ee5252>"..count_show.."<->"
    else
    	count_show = count_show
    end
    local rich_txt = GameConfig.getLanguageWithSwap("#tid_pvp_des001", challenge_count, count_show)
	jf_panel.rich_1:setString(rich_txt)

end

-- 更新兑换(排名)气泡信息
function ArenaMainView:updateRankExchangeBubble()
	local historyTopRank = PVPModel:getHistoryTopRank()	
	local ex_panel = self.panel_qipao2
	local nextExchangeId = FuncPvp.getNextExchangeIdByRnak(historyTopRank)
	local nextExchangeData = FuncPvp.getRankExchange(nextExchangeId)
	local reward_str = {reward = nextExchangeData.reward[1]}
	if PVPModel:hasGetAllRankExchanges() then
		ex_panel.mc_1:showFrame(2)
	else
		ex_panel.mc_1:showFrame(1)
		local leftNum = PVPModel:getRankExchangesUnreceivedNum()
		if leftNum > 0 then
			ex_panel.mc_1.currentView.panel_shu:setVisible(true)
			ex_panel.mc_1.currentView.panel_shu.txt_lvl:setString(leftNum)
		else
			ex_panel.mc_1.currentView.panel_shu:setVisible(false)
		end		
	end
	
	
	ex_panel.mc_1.currentView.UI_1:setResItemData(reward_str)
    ex_panel.mc_1.currentView.UI_1:showResItemName(false)
    local str_show = ""
    if historyTopRank > nextExchangeData.condition then
    	str_show = str_show.."<color = ee5252>"..nextExchangeData.condition.."<->"
    else
    	str_show = nextExchangeData.condition
    end
    local rich_txt = GameConfig.getLanguageWithSwap("#tid_pvp_des002", str_show)
	ex_panel.rich_1:setString(rich_txt)
end

-- 更新商店(显示在商店右侧的)气泡
function ArenaMainView:updateShopBubble()
	local pvp_challengeTimes = PVPModel:challengeTimes()
	-- echo("\n\npvp_challengeTimes===", pvp_challengeTimes)
	local locked_data = FuncShop.getPvpShopLockedGoods()
	local reward_str = nil
	local need_count = nil
	for i,v in ipairs(locked_data) do
		local condition = v.condition
		local reward = nil
		if v.itemId then
			reward = v.type..","..v.itemId..","..v.num
		else
			reward = v.type..","..v.num
		end
		if pvp_challengeTimes < condition then
			reward_str = {reward = reward}
			need_count = condition
			break
		end
	end

	if reward_str and need_count then
		self.panel_qipao3.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_pvp_des003", "<color = ee5252>"..(need_count - pvp_challengeTimes).."<->"))
		self.panel_qipao3.UI_1:setResItemData(reward_str)
		self.panel_qipao3.UI_1:showResItemName(false)
	else
		self.needHideShopBubble = true
		self.panel_qipao3:setVisible(false)
	end
end

function ArenaMainView:updateBuffBtn()
	local buffData = FuncPvp.getBuffDataByBuffId(self.buffId)
	local themeName = GameConfig.getLanguage(buffData.themeName)
	self.btn_bzjc:getUpPanel().txt_1:setString(GameConfig.getLanguageWithSwap("#tid_pvp_des005" ,themeName))
	self.btn_bzjc:setVisible(true)
end

return ArenaMainView
